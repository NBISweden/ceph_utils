#!/bin/sh

# install the first node
cephadm bootstrap --mon-ip 10.10.11.1 --cluster-network 10.10.11.0/24 | tee /root/ceph-bootstrap-installation.log

# since this script is running as root, and the remaining commands should be run as the ubuntu user

sudo -u ubuntu bash <<'EOF'
# clone git repo
cd
git clone https://github.com/NBISweden/ceph_utils.git
cd ceph_utils/node_setup

# create node_list.txt
echo "ubuntu@10.10.11.2" > node_list.txt
echo "ubuntu@10.10.11.3" >> node_list.txt
echo "ubuntu@10.10.11.4" >> node_list.txt
echo "ubuntu@10.10.11.5" >> node_list.txt

# add the ceph public key to nodes
./create_ssh_key_adder.sh
./node_copy.sh ssh_key_adder.sh /home/ubuntu/
./node_executor.sh -p sudo /home/ubuntu/ssh_key_adder.sh
EOF

# add the nodes to the ceph cluster
ceph orch host add ceph-01 10.10.11.2
ceph orch host add ceph-02 10.10.11.3
ceph orch host add ceph-03 10.10.11.4
ceph orch host add ceph-04 10.10.11.5

