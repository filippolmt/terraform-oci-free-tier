#!/bin/bash

sudo sudo sed -i "s/^#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf

# Add Docker's official GPG key:
sudo apt-get update && apt-get upgrade -y && apt-get autoremove -y
sudo apt-get install ca-certificates curl gnupg file vim -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Add user to docker group
sudo usermod -aG docker ubuntu

# Add additional SSH public key
if [ -n "${ADDITIONAL_SSH_PUB_KEY}" ]; then
  grep -qxf "${ADDITIONAL_SSH_PUB_KEY}" /home/ubuntu/.ssh/authorized_keys || echo "${ADDITIONAL_SSH_PUB_KEY}" >>/home/ubuntu/.ssh/authorized_keys
fi

# Mount disk
MNT_DIR=/mnt/data

sudo mkdir -p $MNT_DIR
grep -q "$MNT_DIR" /etc/fstab || echo "/dev/sdb $MNT_DIR ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab

DISK_IS_FORMATTED=$(sudo file -s /dev/sdb | grep -c "ext4 filesystem data")

if [ "$DISK_IS_FORMATTED" -eq 0 ]; then
  sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
fi

FSTAB_ENTRY="/dev/sdb $MNT_DIR ext4 defaults,nofail 0 2"

# Check if a specific entry is present in /etc/fstab file. If not found, appends the entry to the file and mounts all filesystems.
if ! grep -qF "$FSTAB_ENTRY" /etc/fstab; then
  echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab
  sudo mount -a
fi

# Attempts to mount a disk at a specified directory up to a maximum number of attempts.
# If successful, logs the number of attempts in a file; otherwise, logs the failure and exits with status 1.
MAX_ATTEMPTS=20
ATTEMPT=1
MOUNT_SUCCESS=false

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
  if mountpoint -q $MNT_DIR; then
    MOUNT_SUCCESS=true
    break
  fi

  sudo mount -a

  sleep 5
  ATTEMPT=$((ATTEMPT + 1))
done

if [ "$MOUNT_SUCCESS" = true ]; then
  echo "Disk mounted successfully after $ATTEMPT attempts." | sudo tee -a /var/log/mount.log
else
  echo "Mounting disk failed after $MAX_ATTEMPTS attempts." | sudo tee -a /var/log/mount.log
  exit 1
fi

# Install Runtipi
if [ "${INSTALL_RUNTIPI}" == "true" ]; then

  if [ ! -d $MNT_DIR/runtipi ]; then
    cd $MNT_DIR || exit
    curl -L https://setup.runtipi.io | sudo bash
  else
    START_RUNTIPI="true"
  fi

  # Create docker-compose files configuration for Runtipi
  RUNTIPI_CONFIG_FILE=$MNT_DIR/runtipi/user-config/tipi-compose.yml
  if [ ! -f $RUNTIPI_CONFIG_FILE ]; then
    sudo tee "$RUNTIPI_CONFIG_FILE" <<EOL >/dev/null
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
  fi

  # Create docker-compose files configuration for AdGuard
  AD_GUARD_COMPOSE_FILE=$MNT_DIR/runtipi/user-config/adguard/docker-compose.yml
  if [ ! -f $AD_GUARD_COMPOSE_FILE ]; then
    sudo mkdir -p $MNT_DIR/runtipi/user-config/adguard
    sudo tee "$AD_GUARD_COMPOSE_FILE" <<EOL >/dev/null
services:
  adguard:
    networks:
      tipi_main_network:
        ipv4_address: ${RUNTIPI_ADGUARD_IP}
EOL
  fi

  # Create docker-compose files configuration for wireguard
  WIREGUARD_COMPOSE_FILE=$MNT_DIR/runtipi/user-config/wg-easy/docker-compose.yml
  if [ ! -f $WIREGUARD_COMPOSE_FILE ]; then
    sudo mkdir -p $MNT_DIR/runtipi/user-config/wg-easy
    sudo tee "$WIREGUARD_COMPOSE_FILE" <<EOL >/dev/null
services:
  wg-easy:
    environment:
      WG_HOST: "$${WIREGUARD_HOST}"
      PASSWORD: "$${WIREGUARD_PASSWORD}"
      WG_DEFAULT_DNS: "$${WIREGUARD_DNS:-8.8.8.8}"
      WG_ALLOWED_IPS: "${RUNTIPI_MAIN_NETWORK_SUBNET}"
EOL
  fi

  # Start Runtipi if is not installed
  if [ "$START_RUNTIPI" == "true" ]; then
    cd $MNT_DIR/runtipi || exit
    sudo ./runtipi-cli start
  fi
fi
