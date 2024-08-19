#!/bin/bash

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg file vim -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
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

# Verifica se l'entry esiste già in /etc/fstab
if ! grep -qF "$FSTAB_ENTRY" /etc/fstab; then
    echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab
    sudo mount -a
fi

# Tenta di montare il disco fino a 20 volte se non è già montato
MAX_ATTEMPTS=20
ATTEMPT=1
MOUNT_SUCCESS=false

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    if mountpoint -q $MNT_DIR; then
        MOUNT_SUCCESS=true
        break
    fi

    # Se non è montato, prova a montare
    sudo mount -a

    # Attendere 1 secondo tra i tentativi
    sleep 1
    ATTEMPT=$((ATTEMPT + 1))
done

if [ "$MOUNT_SUCCESS" = true ]; then
    echo "Disk mounted successfully after $ATTEMPT attempts." | sudo tee -a /var/log/mount.log
else
    echo "Mounting disk failed after $MAX_ATTEMPTS attempts." | sudo tee -a /var/log/mount.log
    exit 1
fi

# Install Runtipi
if [ ! -d $MNT_DIR/runtipi ] && [ "${INSTALL_RUNTIPI}" == "true" ]; then

    cd $MNT_DIR || exit
    curl -L https://setup.runtipi.io | sudo bash

    # Create docker-compose files configuration for Runtipi
    RUNTIPI_CONFIG_FILE=$MNT_DIR/runtipi/user-config/tipi-compose.yml
    if [ ! -f $RUNTIPI_CONFIG_FILE ]; then
        sudo tee "$RUNTIPI_CONFIG_FILE" <<EOL >/dev/null
services:
  runtipi-reverse-proxy:
    networks:
      tipi_main_network:
        ipv4_address: 172.18.0.254
networks:
  tipi_main_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.18.0.0/16
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
        ipv4_address: 172.18.0.253
EOL
    fi
fi
