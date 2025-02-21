#!/bin/sh

DEBIAN_FRONTEND=noninteractive apt-get install -y python3-venv

sudo -u ubuntu bash <<'EOF'
# update git repo
cd ~/ceph_utils/
git pull

# create venv and install awscli
cd ~/ceph_utils/benchmarks
python3 -m venv venv
source venv/bin/activate
pip3 install -U pip
pip3 install -r requirements.txt

EOF

# ssh to each node and run
# aws configure --profile=ceph
# get access key and secret key for the fega user from the ceph web ui

# start netdata
cd /home/ubuntu/ceph_utils/node_setup
docker compose -f setup-40-netdata-docker-compose.yaml up -d

# copy the streaming file to netdataconfig and restart
mv /home/ubuntu/stream.conf /var/lib/docker/volumes/netdata_netdataconfig/_data/
docker compose -f setup-40-netdata-docker-compose.yaml down
docker compose -f setup-40-netdata-docker-compose.yaml up -d
