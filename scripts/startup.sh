#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

LOG_FILE="/var/log/setup_script.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

# Verify that the script is running as root
if [ "$EUID" -ne 0 ]; then
  exec sudo bash "$0" "$@"
fi

# Get the non-root user
USER_NAME="ubuntu"
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"

log "Set needrestart to automatic mode"

perl -pi -e "s/^#?\s*\$nrconf{restart} = '.*?';/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf

log "Update and upgrade the system"
apt-get update && apt-get upgrade -y && apt-get autoremove -y

log "Install necessary packages"
apt-get install -y ca-certificates curl gnupg file vim

log "Install Docker"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
  tee /etc/apt/sources.list.d/docker.list >/dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
usermod -aG docker "$USER_NAME"

# Add additional SSH public key
if [ -n "${ADDITIONAL_SSH_PUB_KEY}" ]; then
  log "Add additional SSH public key"
  AUTHORIZED_KEYS_FILE="$USER_HOME/.ssh/authorized_keys"
  mkdir -p "$(dirname "$AUTHORIZED_KEYS_FILE")"
  chmod 700 "$(dirname "$AUTHORIZED_KEYS_FILE")"
  touch "$AUTHORIZED_KEYS_FILE"
  chmod 600 "$AUTHORIZED_KEYS_FILE"
  chown "$USER_NAME":"$USER_NAME" "$AUTHORIZED_KEYS_FILE"
  grep -qxF "${ADDITIONAL_SSH_PUB_KEY}" "$AUTHORIZED_KEYS_FILE" || echo "${ADDITIONAL_SSH_PUB_KEY}" >>"$AUTHORIZED_KEYS_FILE"
fi

# Mount disk
MNT_DIR="/mnt/data"
DEVICE="/dev/sdb"

if [ ! -b "$DEVICE" ]; then
  log "Error: Block device $DEVICE does not exist"
  exit 1
fi

log "Mount disk $DEVICE to $MNT_DIR"
mkdir -p "$MNT_DIR"

DISK_IS_FORMATTED=$(file -s "$DEVICE" | grep -c "ext4 filesystem data")

if [ "$DISK_IS_FORMATTED" -eq 0 ]; then
  log "Format disk $DEVICE to ext4"
  mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard "$DEVICE"
fi

FSTAB_ENTRY="$DEVICE $MNT_DIR ext4 defaults,nofail 0 2"

if ! grep -qF "$FSTAB_ENTRY" /etc/fstab; then
  echo "$FSTAB_ENTRY" | tee -a /etc/fstab
fi

# Attempts to mount a disk at a specified directory up to a maximum number of attempts.
# If successful, logs the number of attempts in a file; otherwise, logs the failure and exits with status 1.
MAX_ATTEMPTS=20
for ((ATTEMPT = 1; ATTEMPT <= MAX_ATTEMPTS; ATTEMPT++)); do
  mount "$MNT_DIR"
  if mountpoint -q "$MNT_DIR"; then
    log "Disk $DEVICE mounted to $MNT_DIR after $ATTEMPT attempts."
    break
  fi
  sleep 5
done

# Verify that the disk is mounted
if ! mountpoint -q "$MNT_DIR"; then
  log "Failed to mount disk $DEVICE to $MNT_DIR after $MAX_ATTEMPTS attempts."
  exit 1
fi

# Install Runtipi
if [ "${INSTALL_RUNTIPI}" == "true" ]; then
  log "Install Runtipi"
  if [ ! -d "$MNT_DIR/runtipi" ]; then
    cd "$MNT_DIR" || exit
    curl -L https://setup.runtipi.io | bash
  fi

  # Configure Runtipi
  RUNTIPI_CONFIG_FILE="$MNT_DIR/runtipi/user-config/tipi-compose.yml"
  if [ ! -f "$RUNTIPI_CONFIG_FILE" ]; then
    cat >"$RUNTIPI_CONFIG_FILE" <<EOL
services:
  runtipi-reverse-proxy:
    networks:
      tipi_main_network:
        ipv4_address: ${RUNTIPI_REVERSE_PROXY_IP}
networks:
  tipi_main_network:
    driver: bridge
    ipam:
      config:
        - subnet: ${RUNTIPI_MAIN_NETWORK_SUBNET}
EOL
    log "Create $RUNTIPI_CONFIG_FILE files configuration for Runtipi"
  fi

  # Configure AdGuard
  AD_GUARD_COMPOSE_FILE="$MNT_DIR/runtipi/user-config/adguard/docker-compose.yml"
  if [ ! -f "$AD_GUARD_COMPOSE_FILE" ]; then
    mkdir -p "$(dirname "$AD_GUARD_COMPOSE_FILE")"
    cat >"$AD_GUARD_COMPOSE_FILE" <<EOL
services:
  adguard:
    networks:
      tipi_main_network:
        ipv4_address: ${RUNTIPI_ADGUARD_IP}
EOL
    log "Create $AD_GUARD_COMPOSE_FILE files configuration for AdGuard"
  fi

  # Configure Wireguard
  WIREGUARD_COMPOSE_FILE="$MNT_DIR/runtipi/user-config/wg-easy/docker-compose.yml"
  if [ ! -f "$WIREGUARD_COMPOSE_FILE" ]; then
    mkdir -p "$(dirname "$WIREGUARD_COMPOSE_FILE")"
    cat >"$WIREGUARD_COMPOSE_FILE" <<EOL
services:
  wg-easy:
    environment:
      WG_HOST: "$${WIREGUARD_HOST}"
      PASSWORD: "$${WIREGUARD_PASSWORD}"
      WG_DEFAULT_DNS: "$${WIREGUARD_DNS:-8.8.8.8}"
      WG_ALLOWED_IPS: "${RUNTIPI_MAIN_NETWORK_SUBNET}"
EOL
    log "Create $WIREGUARD_COMPOSE_FILE files configuration for Wireguard"
  fi

  # Start Runtipi
  cd "$MNT_DIR/runtipi" || exit
  ./runtipi-cli start
  log "Start Runtipi"
fi

# Install and configure Wireguard
if [ -n "${WIREGUARD_CLIENT_CONFIGURATION}" ]; then
  log "Install and configure Wireguard"
  apt-get install -y wireguard
  if ! command -v resolvconf &>/dev/null; then
    ln -s /usr/bin/resolvectl /usr/local/bin/resolvconf

    WIREGUARD_CONF_FILE="/etc/wireguard/wg0.conf"
    echo "${WIREGUARD_CLIENT_CONFIGURATION}" >"$WIREGUARD_CONF_FILE"
    chmod 600 "$WIREGUARD_CONF_FILE"
    log "Create $WIREGUARD_CLIENT_CONFIGURATION file configuration for Wireguard"
  fi

  systemctl enable wg-quick@wg0
  systemctl start wg-quick@wg0
  log "Enable and start Wireguard"
fi
