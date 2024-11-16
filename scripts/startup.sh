#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

LOG_FILE="/var/log/setup_script.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

if [ "$EUID" -ne 0 ]; then
  exec sudo bash "$0" "$@"
fi

log "Set needrestart to automatic mode"
sed -i "s/^#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf

log "Update and upgrade the system"
apt-get update && apt-get upgrade -y && apt-get autoremove -y
log "Install necessary packages"
apt-get install ca-certificates curl gnupg file vim -y
log "Install Docker"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
  tee /etc/apt/sources.list.d/docker.list >/dev/null
apt-get update && apt-get upgrade -y && apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Add user to docker group
usermod -aG docker ubuntu

# Add additional SSH public key
if [ -n "${ADDITIONAL_SSH_PUB_KEY}" ]; then
  log "Add additional SSH public key"
  touch /home/ubuntu/.ssh/authorized_keys
  chmod 600 /home/ubuntu/.ssh/authorized_keys
  chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys
  grep -qxf "${ADDITIONAL_SSH_PUB_KEY}" /home/ubuntu/.ssh/authorized_keys || echo "${ADDITIONAL_SSH_PUB_KEY}" >>/home/ubuntu/.ssh/authorized_keys
fi

# Mount disk
MNT_DIR=/mnt/data
DEVICE="/dev/sdb"

log "Mount disk $DEVICE to $MNT_DIR"

mkdir -p $MNT_DIR
grep -q "$MNT_DIR" /etc/fstab || echo "$DEVICE $MNT_DIR ext4 defaults,nofail 0 2" | tee -a /etc/fstab

DISK_IS_FORMATTED=$(file -s $DEVICE | grep -c "ext4 filesystem data")

if [ "$DISK_IS_FORMATTED" -eq 0 ]; then
  log "Format disk $DEVICE to ext4"
  mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard $DEVICE
fi

FSTAB_ENTRY="$DEVICE $MNT_DIR ext4 defaults,nofail 0 2"

# Check if a specific entry is present in /etc/fstab file. If not found, appends the entry to the file and mounts all filesystems.
if ! grep -qF "$FSTAB_ENTRY" /etc/fstab; then
  echo "$FSTAB_ENTRY" | tee -a /etc/fstab
  mount -a
fi

# Attempts to mount a disk at a specified directory up to a maximum number of attempts.
# If successful, logs the number of attempts in a file; otherwise, logs the failure and exits with status 1.
MAX_ATTEMPTS=20
for ((ATTEMPT = 1; ATTEMPT <= MAX_ATTEMPTS; ATTEMPT++)); do
  if mountpoint -q "$MNT_DIR"; then
    log "Disk $DEVICE mounted to $MNT_DIR after $ATTEMPT attempts."
    break
  fi
  mount -a
  sleep 5
done

if ! mountpoint -q "$MNT_DIR"; then
  log "Failed to mount disk $DEVICE to $MNT_DIR after $MAX_ATTEMPTS attempts."
  exit 1
fi

# Install Runtipi
if [ "${INSTALL_RUNTIPI}" == "true" ]; then
  log "Install Runtipi"
  if [ ! -d $MNT_DIR/runtipi ]; then
    cd $MNT_DIR || exit
    curl -L https://setup.runtipi.io | bash
  else
    START_RUNTIPI="true"
  fi

  # Create docker-compose files configuration for Runtipi
  RUNTIPI_CONFIG_FILE=$MNT_DIR/runtipi/user-config/tipi-compose.yml
  if [ ! -f $RUNTIPI_CONFIG_FILE ]; then
    tee "$RUNTIPI_CONFIG_FILE" <<EOL >/dev/null
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

  # Create docker-compose files configuration for AdGuard
  AD_GUARD_COMPOSE_FILE=$MNT_DIR/runtipi/user-config/adguard/docker-compose.yml
  if [ ! -f $AD_GUARD_COMPOSE_FILE ]; then
    mkdir -p $MNT_DIR/runtipi/user-config/adguard
    tee "$AD_GUARD_COMPOSE_FILE" <<EOL >/dev/null
services:
  adguard:
    networks:
      tipi_main_network:
        ipv4_address: ${RUNTIPI_ADGUARD_IP}
EOL
    log "Create $AD_GUARD_COMPOSE_FILE files configuration for AdGuard"
  fi

  # Create docker-compose files configuration for wireguard
  WIREGUARD_COMPOSE_FILE=$MNT_DIR/runtipi/user-config/wg-easy/docker-compose.yml
  if [ ! -f $WIREGUARD_COMPOSE_FILE ]; then
    mkdir -p $MNT_DIR/runtipi/user-config/wg-easy
    tee "$WIREGUARD_COMPOSE_FILE" <<EOL >/dev/null
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

  # Start Runtipi if is not installed
  if [ "$START_RUNTIPI" == "true" ]; then
    cd $MNT_DIR/runtipi || exit
    ./runtipi-cli start
    log "Start Runtipi"
  fi
fi

# Install and configure Wireguard
if [ -n "${WIREGUARD_CLIENT_CONFIGURATION}" ]; then
  log "Install and configure Wireguard"
  apt-get install wireguard -y && ln -s /usr/bin/resolvectl /usr/local/bin/resolvconf
  WIREGUARD_CLIENT_CONFIGURATION_FILE=/etc/wireguard/wg0.conf
  if [ ! -f $WIREGUARD_CLIENT_CONFIGURATION_FILE ]; then
    tee $WIREGUARD_CLIENT_CONFIGURATION_FILE <<EOL >/dev/null
${WIREGUARD_CLIENT_CONFIGURATION}
EOL
    chmod 600 $WIREGUARD_CLIENT_CONFIGURATION_FILE
    log "Create $WIREGUARD_CLIENT_CONFIGURATION_FILE file configuration for Wireguard"
  fi
  systemctl enable wg-quick@wg0
  systemctl start wg-quick@wg0
  log "Enable and start Wireguard"
fi
