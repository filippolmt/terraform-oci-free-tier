#!/bin/bash

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg file vim -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Add user to docker group
sudo usermod -aG docker ubuntu

# Add additional SSH public key
if [ -n "${ADDITIONAL_SSH_PUB_KEY}" ]; then
    grep -qxf "${ADDITIONAL_SSH_PUB_KEY}" /home/ubuntu/.ssh/authorized_keys || echo "${ADDITIONAL_SSH_PUB_KEY}" >>/home/ubuntu/.ssh/authorized_keys
fi

# Mount disk
MNT_DIR=/mnt/data

sudo mkdir -p $MNT_DIR
grep -q "$MNT_DIR" /etc/fstab || echo "/dev/sdb $MNT_DIR ext4 defaults,nofail 0 2" >>/etc/fstab

DISK_IS_FORMATTED=$(sudo file -s /dev/sdb | grep -c "ext4 filesystem data")

if [ "$DISK_IS_FORMATTED" -eq 0 ]; then
    sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
fi

sudo mount -a

if [ ! -d $MNT_DIR ]; then
    echo "Mounting disk failed"
    exit 1
fi

# Install Runtipi
if [ ! -d $MNT_DIR/runtipi ] && [ "${INSTALL_RUNTIPI}" == "true" ]; then
    cd $MNT_DIR || exit
    sudo curl -L https://setup.runtipi.io | bash
fi
