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

log "=== Phase A: System packages and Docker installation ==="

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
  SSH_DIR="$USER_HOME/.ssh"
  AUTHORIZED_KEYS_FILE="$SSH_DIR/authorized_keys"
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"
  touch "$AUTHORIZED_KEYS_FILE"
  chmod 600 "$AUTHORIZED_KEYS_FILE"
  chown "$USER_NAME":"$USER_NAME" "$SSH_DIR"
  chown "$USER_NAME":"$USER_NAME" "$AUTHORIZED_KEYS_FILE"
  grep -qxF "${ADDITIONAL_SSH_PUB_KEY}" "$AUTHORIZED_KEYS_FILE" || cat >>"$AUTHORIZED_KEYS_FILE" <<'SSH_KEY'
${ADDITIONAL_SSH_PUB_KEY}
SSH_KEY
fi

# =============================================================================
# Phase B: Block volume setup script (runs as systemd oneshot service)
#
# Written here and executed by mnt-data-setup.service to decouple volume mount
# from cloud-init. Terraform creates the volume attachment AFTER the instance
# reaches RUNNING state, so cloud-init cannot reliably wait for the device.
# The systemd service waits with exponential backoff (up to 60 minutes).
#
# NOTE: Terraform templatefile() interpolates the ENTIRE file before bash runs.
# All template references become literal values in the Phase B script.
# Bash variables use $VAR (no braces) and pass through Terraform untouched.
# =============================================================================
log "Writing block volume setup script to /opt/mnt-data-setup.sh"
cat >/opt/mnt-data-setup.sh <<'PHASE_B_EOF'
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

cleanup() {
  local exit_code=$?
  if [ $exit_code -ne 0 ]; then
    log_error "Block volume setup failed with exit code $exit_code"
    log_error "Check $LOG_FILE or run: journalctl -u mnt-data-setup.service"
  fi
  exit $exit_code
}

trap cleanup EXIT

export DEBIAN_FRONTEND=noninteractive

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

log "=== Phase B: Block volume setup and application configuration ==="

MNT_DIR="/mnt/data"

# Skip device detection and mount if already mounted (idempotent re-run)
if mountpoint -q "$MNT_DIR"; then
  log "Block volume already mounted at $MNT_DIR, skipping detection and mount"
else
  # Auto-detect the secondary block device (not the boot disk)
  # Uses exponential backoff with 60-minute hard cap to handle Terraform
  # volume attachment timing (attachment starts after instance is RUNNING)
  log "Detecting secondary block device"
  BOOT_DEVICE=$(findmnt -n -o SOURCE / | sed 's/[0-9]*$//' | sed 's/p$//')
  DEVICE=""
  MAX_WAIT=3600
  ELAPSED=0
  INTERVAL=10

  while [ $ELAPSED -lt $MAX_WAIT ]; do
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

    log "Waiting for block volume to attach ($ELAPSED s elapsed, next check in $INTERVAL s)..."
    sleep "$INTERVAL"
    ELAPSED=$((ELAPSED + INTERVAL))
    # Exponential backoff: 10, 15, 22, 33, 49, 60, 60, 60...
    INTERVAL=$((INTERVAL * 3 / 2))
    if [ $INTERVAL -gt 60 ]; then
      INTERVAL=60
    fi
  done

  # Fallback to /dev/sdb only after all detection attempts are exhausted
  if [ -z "$DEVICE" ]; then
    if [ -b "/dev/sdb" ] && [ "/dev/sdb" != "$BOOT_DEVICE" ] \
       && ! lsblk -n "/dev/sdb" | grep -q "part" \
       && ! findmnt -n "/dev/sdb" >/dev/null 2>&1; then
      DEVICE="/dev/sdb"
      log "Fallback to default device: $DEVICE"
    else
      log_error "No secondary block device found after $MAX_WAIT s"
      exit 1
    fi
  fi

  # Mount disk
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
fi

# Ensure Docker waits for the block volume mount on reboot.
# Without this, Docker may start before /mnt/data is mounted, causing
# Coolify/RunTipi containers to see an empty directory via the symlink.
MNT_UNIT=$(systemd-escape --path "$MNT_DIR").mount
DOCKER_OVERRIDE="/etc/systemd/system/docker.service.d"
if [ ! -f "$DOCKER_OVERRIDE/wait-for-mount.conf" ]; then
  mkdir -p "$DOCKER_OVERRIDE"
  cat >"$DOCKER_OVERRIDE/wait-for-mount.conf" <<EOF
[Unit]
After=$MNT_UNIT
Requires=$MNT_UNIT
EOF
  systemctl daemon-reload
  log "Docker configured to wait for $MNT_DIR mount on boot"
fi

# Install Runtipi
if [ "${INSTALL_RUNTIPI}" == "true" ]; then
  log "Install Runtipi"
  RUNTIPI_HOME="$MNT_DIR/runtipi"
  RUNTIPI_USER_CONFIG="$RUNTIPI_HOME/user-config"

  if [ ! -d "$RUNTIPI_HOME" ]; then
    # Download Runtipi installer to a file instead of piping to bash
    RUNTIPI_INSTALLER="/tmp/runtipi-setup.sh"
    log "Downloading Runtipi installer..."
    retry 3 10 curl -fsSL https://setup.runtipi.io -o "$RUNTIPI_INSTALLER"

    # Make executable and run (subshell to preserve working directory)
    chmod +x "$RUNTIPI_INSTALLER"
    log "Running Runtipi installer..."
    (cd "$MNT_DIR" && bash "$RUNTIPI_INSTALLER")
    rm -f "$RUNTIPI_INSTALLER"
  fi

  # Configure Runtipi
  RUNTIPI_CONFIG_FILE="$RUNTIPI_USER_CONFIG/tipi-compose.yml"
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
  AD_GUARD_COMPOSE_FILE="$RUNTIPI_USER_CONFIG/adguard/docker-compose.yml"
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
  WIREGUARD_COMPOSE_FILE="$RUNTIPI_USER_CONFIG/wg-easy/docker-compose.yml"
  if [ ! -f "$WIREGUARD_COMPOSE_FILE" ]; then
    mkdir -p "$(dirname "$WIREGUARD_COMPOSE_FILE")"
    cat >"$WIREGUARD_COMPOSE_FILE" <<'EOL'
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
  (cd "$RUNTIPI_HOME" && ./runtipi-cli start)
  log "Start Runtipi"
fi

# Install Coolify
if [ "${INSTALL_COOLIFY}" == "true" ]; then
  log "Install Coolify"

  # Redirect Coolify data to block volume via symlink
  COOLIFY_DATA="$MNT_DIR/coolify"
  COOLIFY_HOME="/data/coolify"
  COOLIFY_SOURCE="$COOLIFY_HOME/source"
  COOLIFY_ENV="$COOLIFY_SOURCE/.env"

  mkdir -p "$COOLIFY_DATA"
  if [ ! -e "$COOLIFY_HOME" ]; then
    mkdir -p /data
    ln -sf "$COOLIFY_DATA" "$COOLIFY_HOME"
  elif [ -L "$COOLIFY_HOME" ]; then
    LINK_TARGET=$(readlink -f "$COOLIFY_HOME")
    if [ "$LINK_TARGET" != "$(readlink -f "$COOLIFY_DATA")" ]; then
      log_error "$COOLIFY_HOME is a symlink to $LINK_TARGET instead of $COOLIFY_DATA — data may not be on the block volume"
      exit 1
    fi
  else
    log_error "$COOLIFY_HOME exists as a regular directory — data is on the boot volume, not the block volume. Remove it and re-run to use the block volume."
    exit 1
  fi

  # Configure installer environment variables
  # Use a boolean flag (resolved at OpenTofu plan time) instead of [ -n "$CREDENTIAL" ]
  # to avoid bash-expanding $-containing passwords under set -u (crash on unbound vars).
  # The quoted heredocs safely transfer the raw credential values without expansion.
  if [ "${COOLIFY_HAS_ADMIN_CREDS}" == "true" ]; then
    export ROOT_USERNAME
    read -r ROOT_USERNAME <<'CRED_USER'
${COOLIFY_ADMIN_EMAIL}
CRED_USER
    export ROOT_USER_EMAIL
    read -r ROOT_USER_EMAIL <<'CRED_EMAIL'
${COOLIFY_ADMIN_EMAIL}
CRED_EMAIL
    export ROOT_USER_PASSWORD
    read -r ROOT_USER_PASSWORD <<'CRED_PASS'
${COOLIFY_ADMIN_PASSWORD}
CRED_PASS
  fi
  if [ "${COOLIFY_AUTO_UPDATE}" == "true" ]; then
    export AUTOUPDATE=true
  else
    export AUTOUPDATE=false
  fi

  # Download and run installer (skip if already installed)
  if [ ! -f "$COOLIFY_ENV" ]; then
    COOLIFY_INSTALLER="/tmp/coolify-install.sh"
    log "Downloading Coolify installer..."
    retry 3 10 curl -fsSL https://cdn.coollabs.io/coolify/install.sh -o "$COOLIFY_INSTALLER"
    chmod +x "$COOLIFY_INSTALLER"

    log "Running Coolify installer..."
    bash "$COOLIFY_INSTALLER"
    rm -f "$COOLIFY_INSTALLER"
  else
    log "Coolify already installed, skipping installer"
    (cd "$COOLIFY_SOURCE" && docker compose up -d)
    log "Started existing Coolify installation"
  fi

  log "Coolify setup completed"
fi

# Install and configure Wireguard
if [ -n "${WIREGUARD_CLIENT_CONFIGURATION}" ]; then
  log "Install and configure Wireguard"
  retry 3 10 apt-get -o DPkg::Lock::Timeout=60 install -y wireguard
  if ! command -v resolvconf &>/dev/null; then
    ln -sf /usr/bin/resolvectl /usr/local/bin/resolvconf
  fi

  WIREGUARD_CONF_FILE="/etc/wireguard/wg0.conf"
  cat >"$WIREGUARD_CONF_FILE" <<'WG_CONF'
${WIREGUARD_CLIENT_CONFIGURATION}
WG_CONF
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
PHASE_B_EOF

chmod +x /opt/mnt-data-setup.sh

# =============================================================================
# Systemd unit: runs Phase B after Docker is available
# =============================================================================
log "Writing mnt-data-setup.service systemd unit"
cat >/etc/systemd/system/mnt-data-setup.service <<'SYSTEMD_UNIT'
[Unit]
Description=Mount block volume and configure applications
After=network-online.target docker.service
Wants=network-online.target
ConditionPathExists=!/var/log/.setup_script_completed

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/opt/mnt-data-setup.sh
TimeoutStartSec=3900
StandardOutput=journal+console
StandardError=journal+console

[Install]
WantedBy=multi-user.target
SYSTEMD_UNIT

systemctl daemon-reload
systemctl enable --now mnt-data-setup.service

log "Phase A complete — mnt-data-setup.service will handle volume mount and application setup"
log "Monitor progress: journalctl -u mnt-data-setup.service -f"
