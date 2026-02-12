#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

LOG_FILE="/var/log/setup_script.log"
COMPLETION_MARKER="/var/log/.setup_script_completed"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

log_error() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: $*" | tee -a "$LOG_FILE" >&2
}

# Cleanup function for error handling
cleanup() {
  local exit_code=$?
  if [ $exit_code -ne 0 ]; then
    log_error "Script failed with exit code $exit_code"
    log_error "Check $LOG_FILE for details"
  fi
  exit $exit_code
}

trap cleanup EXIT

# Check if script already completed successfully
if [ -f "$COMPLETION_MARKER" ]; then
  log "Setup script already completed. Skipping. Remove $COMPLETION_MARKER to re-run."
  exit 0
fi

# Verify that the script is running as root
if [ "$EUID" -ne 0 ]; then
  log "Elevating privileges with sudo"
  exec sudo bash "$0" "$@"
fi

# Prevent interactive prompts from apt during cloud-init
export DEBIAN_FRONTEND=noninteractive

# Get the non-root user
USER_NAME="ubuntu"
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"

# Retry function for commands that may fail due to network issues
retry() {
  local max_attempts="$1"
  local delay="$2"
  shift 2
  local attempt=1

  while [ "$attempt" -le "$max_attempts" ]; do
    if "$@"; then
      return 0
    fi
    log "Attempt $attempt/$max_attempts failed for: $*"
    if [ "$attempt" -lt "$max_attempts" ]; then
      log "Retrying in $delay seconds..."
      sleep "$delay"
    fi
    attempt=$((attempt + 1))
  done

  log_error "All $max_attempts attempts failed for: $*"
  return 1
}

# Set needrestart to automatic mode
log "Set needrestart to automatic mode"
if [ -f /etc/needrestart/needrestart.conf ]; then
  perl -pi -e "s/^#?\s*\\\$nrconf{restart} = '.*?';/\\\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
else
  log "needrestart.conf not found, skipping"
fi

# Add Docker APT repository before updating package lists (single apt-get update)
# Use .asc (ASCII-armored) key directly — avoids requiring gpg binary (not in Ubuntu Minimal)
log "Add Docker APT repository"
install -m 0755 -d /etc/apt/keyrings
retry 3 10 curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
  tee /etc/apt/sources.list.d/docker.list >/dev/null

# Wait for any existing apt locks (unattended-upgrades may run at first boot)
log "Update, upgrade, and install all packages"
retry 5 30 apt-get -o DPkg::Lock::Timeout=60 update
retry 3 10 apt-get -o DPkg::Lock::Timeout=60 -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade -y
apt-get -o DPkg::Lock::Timeout=60 autoremove -y
retry 3 10 apt-get -o DPkg::Lock::Timeout=60 install -y \
  ca-certificates curl file vim \
  docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

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
  chown "$USER_NAME":"$USER_NAME" "$(dirname "$AUTHORIZED_KEYS_FILE")"
  grep -qxF "${ADDITIONAL_SSH_PUB_KEY}" "$AUTHORIZED_KEYS_FILE" || echo "${ADDITIONAL_SSH_PUB_KEY}" >>"$AUTHORIZED_KEYS_FILE"
fi

# Auto-detect the secondary block device (not the boot disk)
# Retry detection because the volume attachment may still be in progress
log "Detecting secondary block device"
BOOT_DEVICE=$(findmnt -n -o SOURCE / | sed 's/[0-9]*$//' | sed 's/p$//')
DEVICE=""
DETECT_MAX_ATTEMPTS=30

for ((DETECT_ATTEMPT = 1; DETECT_ATTEMPT <= DETECT_MAX_ATTEMPTS; DETECT_ATTEMPT++)); do
  for dev in /dev/sdb /dev/sdc /dev/sdd /dev/vdb /dev/vdc /dev/vdd /dev/nvme1n1 /dev/nvme2n1; do
    if [ -b "$dev" ] && [ "$dev" != "$BOOT_DEVICE" ]; then
      # Check if device has no partitions and is not mounted
      if ! lsblk -n "$dev" | grep -q "part" && ! findmnt -n "$dev" >/dev/null 2>&1; then
        DEVICE="$dev"
        log "Found secondary block device: $DEVICE"
        break 2
      fi
    fi
  done

  log "Waiting for block volume to attach (attempt $DETECT_ATTEMPT/$DETECT_MAX_ATTEMPTS)..."
  sleep 10
done

# Fallback to /dev/sdb only after all detection attempts are exhausted
if [ -z "$DEVICE" ]; then
  if [ -b "/dev/sdb" ] && [ "/dev/sdb" != "$BOOT_DEVICE" ] \
     && ! lsblk -n "/dev/sdb" | grep -q "part" \
     && ! findmnt -n "/dev/sdb" >/dev/null 2>&1; then
    DEVICE="/dev/sdb"
    log "Fallback to default device: $DEVICE"
  else
    log_error "No secondary block device found after $DETECT_MAX_ATTEMPTS attempts"
    exit 1
  fi
fi

# Mount disk
MNT_DIR="/mnt/data"

log "Mount disk $DEVICE to $MNT_DIR"
mkdir -p "$MNT_DIR"

# Check if disk is formatted (use || true to prevent set -e from triggering)
DISK_IS_FORMATTED=$(file -s "$DEVICE" | grep -c "ext4 filesystem data" || true)

if [ "$DISK_IS_FORMATTED" -eq 0 ]; then
  log "Format disk $DEVICE to ext4 (lazy init, background completion after mount)"
  mkfs.ext4 -m 0 -F -E lazy_itable_init=1,lazy_journal_init=1,discard "$DEVICE"
fi

# Use UUID for fstab (device paths like /dev/sdb can change between reboots)
# Retry blkid because UUID may not be immediately available after mkfs with lazy init
DEVICE_UUID=""
for ((UUID_ATTEMPT = 1; UUID_ATTEMPT <= 10; UUID_ATTEMPT++)); do
  DEVICE_UUID=$(blkid -s UUID -o value "$DEVICE" 2>/dev/null || true)
  if [ -n "$DEVICE_UUID" ]; then
    break
  fi
  log "Waiting for UUID to become available (attempt $UUID_ATTEMPT/10)..."
  sleep 2
done

if [ -z "$DEVICE_UUID" ]; then
  log_error "Failed to retrieve UUID for $DEVICE"
  exit 1
fi

log "Device $DEVICE has UUID=$DEVICE_UUID"
FSTAB_ENTRY="UUID=$DEVICE_UUID $MNT_DIR ext4 defaults,nofail,noatime,commit=60 0 2"

if ! grep -qF "UUID=$DEVICE_UUID" /etc/fstab; then
  echo "$FSTAB_ENTRY" | tee -a /etc/fstab
fi

# Attempts to mount a disk at a specified directory up to a maximum number of attempts.
MAX_ATTEMPTS=20
for ((ATTEMPT = 1; ATTEMPT <= MAX_ATTEMPTS; ATTEMPT++)); do
  if mount "$MNT_DIR" 2>/dev/null; then
    if mountpoint -q "$MNT_DIR"; then
      log "Disk $DEVICE mounted to $MNT_DIR after $ATTEMPT attempts."
      break
    fi
  fi
  if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
    sleep 5
  fi
done

# Verify that the disk is mounted
if ! mountpoint -q "$MNT_DIR"; then
  log_error "Failed to mount disk $DEVICE to $MNT_DIR after $MAX_ATTEMPTS attempts."
  exit 1
fi

# Install Runtipi
if [ "${INSTALL_RUNTIPI}" == "true" ]; then
  log "Install Runtipi"
  if [ ! -d "$MNT_DIR/runtipi" ]; then
    cd "$MNT_DIR" || exit

    # Download Runtipi installer to a file instead of piping to bash
    RUNTIPI_INSTALLER="/tmp/runtipi-setup.sh"
    log "Downloading Runtipi installer..."
    retry 3 10 curl -fsSL https://setup.runtipi.io -o "$RUNTIPI_INSTALLER"

    # Make executable and run
    chmod +x "$RUNTIPI_INSTALLER"
    log "Running Runtipi installer..."
    bash "$RUNTIPI_INSTALLER"
    rm -f "$RUNTIPI_INSTALLER"
  fi

  # Configure Runtipi
  RUNTIPI_CONFIG_FILE="$MNT_DIR/runtipi/user-config/tipi-compose.yml"
  if [ ! -f "$RUNTIPI_CONFIG_FILE" ]; then
    mkdir -p "$(dirname "$RUNTIPI_CONFIG_FILE")"
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
  retry 3 10 apt-get -o DPkg::Lock::Timeout=60 install -y wireguard
  if ! command -v resolvconf &>/dev/null; then
    ln -sf /usr/bin/resolvectl /usr/local/bin/resolvconf
  fi

  WIREGUARD_CONF_FILE="/etc/wireguard/wg0.conf"
  echo "${WIREGUARD_CLIENT_CONFIGURATION}" >"$WIREGUARD_CONF_FILE"
  chmod 600 "$WIREGUARD_CONF_FILE"
  log "Create $WIREGUARD_CONF_FILE file configuration for WireGuard"

  # Enable and start WireGuard (non-fatal: don't block entire setup on failure)
  if systemctl enable --now wg-quick@wg0; then
    sleep 3
    if wg show wg0 >/dev/null 2>&1; then
      log "WireGuard interface initialized successfully"
    else
      log_error "WireGuard interface failed to initialize (check manually with: wg show wg0)"
    fi
  else
    log_error "WireGuard service failed to start (check manually with: systemctl status wg-quick@wg0)"
  fi
fi

# Mark setup as completed
touch "$COMPLETION_MARKER"
log "Setup completed successfully"
