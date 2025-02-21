#!/bin/bash

echo "Post-deployment script setup-10-install-ceph-dependencies.sh running" >> /var/log/post_deploy_setup-10-install-ceph-dependencies.log

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update


# install dependencies
sudo apt-get install -y net-tools cephadm ceph-common docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin smartmontools btop

# get the helper scripts
cd /home/ubuntu
sudo -u ubuntu bash -c "git clone https://github.com/NBISweden/ceph_utils.git"

