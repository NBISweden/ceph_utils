#!/bin/bash

# --- Start MAAS 1.0 script metadata ---
# name: setup-10-install-ceph-dependencies
# title: Install software needed by Ceph
# description: Install software needed by Ceph
# script_type: commissioning
# timeout: 00:05:00
# --- End MAAS 1.0 script metadata ---
# This script is used to commision a node in MAAS

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
sudo apt-get install -y net-tools cephadm ceph-common docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

### run on first ceph node

# bootstrap it as the first monitor running on th especified IP
#sudo cephadm bootstrap --mon-ip 10.10.11.1 --cluster-network 10.10.11.0/24 --ssh-user ubuntu

# add the remaining hosts
#sudo ceph orch host add ceph-01 10.10.11.2
#sudo ceph orch host add ceph-02 10.10.11.3
#sudo ceph orch host add ceph-03 10.10.11.4
#sudo ceph orch host add ceph-04 10.10.11.5




