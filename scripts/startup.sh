#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

readonly LOG_FILE="/var/log/setup_script.log"
readonly COMPLETION_MARKER="/var/log/.setup_script_completed"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

log_error() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: $*" | tee -a "$LOG_FILE" >&2
}

# Cleanup function for error handling
cleanup() {
  local exit_code=$?
  if [ "$exit_code" -ne 0 ]; then
    log_error "Script failed with exit code $exit_code"
    log_error "Check $LOG_FILE for details"
  fi
  exit "$exit_code"
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

# Set timezone.
# timedatectl reconciles /etc/localtime, /etc/timezone and the running clock via
# systemd-timedated; the bare symlink alone left the instance on UTC at cloud-init
# time. Fall back to the symlink only if timedatectl is unavailable.
if timedatectl set-timezone "${TIMEZONE}"; then
  log "Timezone set to ${TIMEZONE} via timedatectl"
else
  ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
  echo "${TIMEZONE}" >/etc/timezone
  log "timedatectl unavailable; timezone set to ${TIMEZONE} via symlink fallback"
fi

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
retry 3 10 apt-get -o DPkg::Lock::Timeout=60 autoremove -y
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
  grep -qxF -- "${ADDITIONAL_SSH_PUB_KEY}" "$AUTHORIZED_KEYS_FILE" || cat >>"$AUTHORIZED_KEYS_FILE" <<'SSH_KEY'
${ADDITIONAL_SSH_PUB_KEY}
SSH_KEY
fi

# =============================================================================
# OS tuning and hardening
#
# Idempotent: drop-in files are overwritten in place, fstab/swap entries are
# guarded against duplicates. Bug fixes (timezone above) apply unconditionally;
# behavior-changing items (swap, auto-reboot, fail2ban, Docker data-root) are
# gated on their Terraform variables and default to off.
# =============================================================================
log "=== Applying OS tuning and hardening ==="

# --- journald disk usage cap (#165.2) ---
JOURNALD_DROPIN="/etc/systemd/journald.conf.d/00-oci-free-tier.conf"
mkdir -p "$(dirname "$JOURNALD_DROPIN")"
cat >"$JOURNALD_DROPIN" <<'JOURNALD_CONF'
[Journal]
SystemMaxUse=200M
Storage=persistent
JOURNALD_CONF
if systemctl restart systemd-journald; then
  log "journald capped at SystemMaxUse=200M (persistent storage)"
else
  log_error "Failed to restart systemd-journald (drop-in written, applies on next boot)"
fi

# --- SSH hardening (#165.4): disable root login and X11 forwarding ---
# Key-only auth is left untouched; login remains via the ubuntu user + sudo.
SSHD_DROPIN="/etc/ssh/sshd_config.d/00-oci-free-tier-hardening.conf"
mkdir -p "$(dirname "$SSHD_DROPIN")"
cat >"$SSHD_DROPIN" <<'SSHD_CONF'
PermitRootLogin no
X11Forwarding no
SSHD_CONF
if sshd -t; then
  systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null || true
  log "SSH hardening applied (PermitRootLogin no, X11Forwarding no)"
else
  log_error "sshd -t validation failed; removing hardening drop-in to avoid breaking SSH"
  rm -f "$SSHD_DROPIN"
fi

# --- Resource limits for container workloads (#165.5) ---
LIMITS_DROPIN="/etc/security/limits.d/00-oci-free-tier.conf"
mkdir -p "$(dirname "$LIMITS_DROPIN")"
cat >"$LIMITS_DROPIN" <<'LIMITS_CONF'
* soft nofile 65535
* hard nofile 65535
root soft nofile 65535
root hard nofile 65535
LIMITS_CONF
log "Open-file limit (nofile) set to 65535"

cat >/etc/sysctl.d/99-oci-free-tier.conf <<'SYSCTL_CONF'
fs.inotify.max_user_instances=512
fs.inotify.max_user_watches=524288
SYSCTL_CONF
log "inotify limits drop-in written (max_user_instances=512, max_user_watches=524288)"

# --- Optional swap file (#164.3) + vm.swappiness (#165.6) ---
if [ "${SWAP_SIZE_GB}" -gt 0 ]; then
  SWAPFILE="/swapfile"
  if [ -f "$SWAPFILE" ] || swapon --show=NAME --noheadings 2>/dev/null | grep -qx "$SWAPFILE"; then
    log "Swapfile $SWAPFILE already present, skipping creation"
  else
    log "Creating ${SWAP_SIZE_GB}G swapfile at $SWAPFILE"
    if ! fallocate -l "${SWAP_SIZE_GB}G" "$SWAPFILE" 2>/dev/null; then
      dd if=/dev/zero of="$SWAPFILE" bs=1G count="${SWAP_SIZE_GB}" status=none
    fi
    chmod 600 "$SWAPFILE"
    mkswap "$SWAPFILE"
    swapon "$SWAPFILE"
    log "Swapfile active (${SWAP_SIZE_GB}G)"
  fi
  # Persist in fstab without duplicating the entry on re-run
  if ! grep -qF "$SWAPFILE" /etc/fstab; then
    echo "$SWAPFILE none swap sw 0 0" >>/etc/fstab
    log "Added swapfile entry to /etc/fstab"
  fi
  # vm.swappiness is only meaningful with swap enabled
  echo "vm.swappiness=10" >/etc/sysctl.d/99-oci-free-tier-swap.conf
  log "vm.swappiness=10 drop-in written"
fi

# Apply all sysctl drop-ins
if sysctl --system >/dev/null 2>&1; then
  log "Applied sysctl drop-ins"
else
  log_error "sysctl --system reported errors (drop-ins written, apply on next boot)"
fi

# --- Optional automatic reboot for unattended-upgrades (#165.3) ---
if [ "${ENABLE_AUTO_REBOOT}" = "true" ]; then
  cat >/etc/apt/apt.conf.d/52-oci-free-tier-auto-reboot <<'AUTO_REBOOT_CONF'
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "${AUTO_REBOOT_TIME}";
AUTO_REBOOT_CONF
  log "Unattended-upgrades automatic reboot enabled at ${AUTO_REBOOT_TIME}"
fi

# --- Optional fail2ban (#165.6) ---
if [ "${ENABLE_FAIL2BAN}" = "true" ]; then
  log "Installing fail2ban (non-fatal)"
  if retry 3 10 apt-get -o DPkg::Lock::Timeout=60 install -y fail2ban; then
    systemctl enable --now fail2ban 2>/dev/null || log_error "fail2ban installed but service failed to start"
  else
    log_error "fail2ban installation failed (non-fatal), continuing"
  fi
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

readonly LOG_FILE="/var/log/setup_script.log"
readonly COMPLETION_MARKER="/var/log/.setup_script_completed"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

log_error() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: $*" | tee -a "$LOG_FILE" >&2
}

cleanup() {
  local exit_code=$?
  if [ "$exit_code" -ne 0 ]; then
    log_error "Block volume setup failed with exit code $exit_code"
    log_error "Check $LOG_FILE or run: journalctl -u mnt-data-setup.service"
  fi
  exit "$exit_code"
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

readonly MNT_DIR="/mnt/data"

# Skip device detection and mount if already mounted (idempotent re-run)
if mountpoint -q "$MNT_DIR"; then
  log "Block volume already mounted at $MNT_DIR, skipping detection and mount"
else
  # Auto-detect the secondary block device (not the boot disk)
  # Uses exponential backoff with 60-minute hard cap to handle Terraform
  # volume attachment timing (attachment starts after instance is RUNNING)
  log "Detecting secondary block device"
  BOOT_DEVICE=$(findmnt -n -o SOURCE / | sed 's/[0-9]*$//;s/p$//')
  DEVICE=""
  MAX_WAIT=3600
  ELAPSED=0
  INTERVAL=10

  while [ "$ELAPSED" -lt "$MAX_WAIT" ]; do
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
    if [ "$INTERVAL" -gt 60 ]; then
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
    if [ "$ATTEMPT" -lt "$MAX_ATTEMPTS" ]; then
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
# containers to see an empty directory via symlinks.
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

# Reconcile the host packet filter with the OCI security list.
# The Oracle Ubuntu image ships an INPUT chain ending in a catch-all REJECT,
# so only SSH is reachable and ports opened in network.tf are dropped at the
# host. The OCI security list is the single source of truth for inbound
# reachability, so remove only that catch-all REJECT (IPv4 + IPv6), leaving
# RELATED,ESTABLISHED, lo, icmp, and SSH rules intact. Guarded/non-fatal.
log "Reconciling host packet filter with OCI security list"
if iptables -C INPUT -j REJECT --reject-with icmp-host-prohibited 2>/dev/null; then
  iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited
  log "Removed IPv4 catch-all REJECT rule from INPUT chain"
else
  log "IPv4 catch-all REJECT rule not present, nothing to remove"
fi

if ip6tables -C INPUT -j REJECT --reject-with icmp6-adm-prohibited 2>/dev/null; then
  ip6tables -D INPUT -j REJECT --reject-with icmp6-adm-prohibited
  log "Removed IPv6 catch-all REJECT rule from INPUT chain"
else
  log "IPv6 catch-all REJECT rule not present, nothing to remove"
fi

# Persist the ruleset so it survives reboot (iptables-persistent ships on the
# Oracle image). Guard against a future base image lacking the tool.
if command -v netfilter-persistent >/dev/null 2>&1; then
  if netfilter-persistent save; then
    log "Persisted netfilter ruleset"
  else
    log_error "netfilter-persistent save failed; firewall change may not persist across reboot"
  fi
else
  log_error "netfilter-persistent not found; firewall change will not persist across reboot"
fi

# Disable network-exposed services with no role on a headless cloud server so
# nothing unexpected keeps listening on 0.0.0.0 once the host filter is relaxed.
# Non-fatal when a unit is not installed.
log "Disabling unused locally-listening services (cups, cups-browsed, rpcbind)"
for svc in cups cups-browsed rpcbind; do
  if systemctl disable --now "$svc" 2>/dev/null; then
    log "Disabled $svc"
  else
    log "$svc not present or already disabled, skipping"
  fi
done

# --- Optional: move Docker data-root to the block volume (#165.6) ---
# One-time, marker-guarded copy-then-switch migration. Runs in Phase B because
# it needs /mnt/data mounted. MERGES "data-root" into any existing
# /etc/docker/daemon.json so log-driver/log-opts and default-address-pools are
# preserved (never overwritten). The source /var/lib/docker is kept (renamed)
# until the new root is verified live.
if [ "${DOCKER_DATA_ROOT_ON_VOLUME}" = "true" ]; then
  DOCKER_MIGRATION_MARKER="/var/log/.docker_dataroot_migrated"
  NEW_DOCKER_ROOT="$MNT_DIR/docker"

  if [ -f "$DOCKER_MIGRATION_MARKER" ]; then
    log "Docker data-root already migrated to $NEW_DOCKER_ROOT, skipping"
  else
    log "Migrating Docker data-root to $NEW_DOCKER_ROOT"
    DAEMON_JSON="/etc/docker/daemon.json"
    mkdir -p /etc/docker "$NEW_DOCKER_ROOT"

    # Merge data-root into daemon.json, preserving existing keys (needs jq)
    if command -v jq >/dev/null 2>&1 || retry 3 10 apt-get -o DPkg::Lock::Timeout=60 install -y jq; then
      if [ -s "$DAEMON_JSON" ]; then
        TMP_JSON="$(mktemp)"
        if jq --arg root "$NEW_DOCKER_ROOT" '. + {"data-root": $root}' "$DAEMON_JSON" >"$TMP_JSON"; then
          mv "$TMP_JSON" "$DAEMON_JSON"
        else
          rm -f "$TMP_JSON"
          log_error "Failed to merge $DAEMON_JSON; aborting Docker migration (data left in place)"
        fi
      else
        echo "{\"data-root\": \"$NEW_DOCKER_ROOT\"}" >"$DAEMON_JSON"
      fi
    else
      log_error "jq unavailable; aborting Docker migration to avoid clobbering $DAEMON_JSON"
    fi

    # Proceed only if daemon.json now references the new root (source of truth)
    if grep -qF "$NEW_DOCKER_ROOT" "$DAEMON_JSON" 2>/dev/null; then
      log "Stopping Docker for data-root migration"
      systemctl stop docker docker.socket 2>/dev/null || true
      # Copy-then-switch: preserve attributes, keep source until verified
      if [ -d /var/lib/docker ] && [ -n "$(ls -A /var/lib/docker 2>/dev/null || true)" ]; then
        log "Copying /var/lib/docker -> $NEW_DOCKER_ROOT"
        cp -a /var/lib/docker/. "$NEW_DOCKER_ROOT/"
      fi
      if systemctl start docker; then
        sleep 3
        if docker info --format '{{.DockerRootDir}}' 2>/dev/null | grep -qF "$NEW_DOCKER_ROOT"; then
          log "Docker now using data-root $NEW_DOCKER_ROOT"
          mv /var/lib/docker "/var/lib/docker.migrated" 2>/dev/null || true
          touch "$DOCKER_MIGRATION_MARKER"
        else
          log_error "Docker did not pick up new data-root; source kept at /var/lib/docker for review"
        fi
      else
        log_error "Docker failed to start after migration; check $DAEMON_JSON and journalctl -u docker"
      fi
    fi
  fi
fi

# Install Runtipi
if [ "${INSTALL_RUNTIPI}" = "true" ]; then
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

  # Start Runtipi (subshell to preserve working directory)
  (cd "$RUNTIPI_HOME" && ./runtipi-cli start)
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
