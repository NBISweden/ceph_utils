
#!/bin/sh

# this script has to be run manually on the master node, and you have to be able to ssh to the worker nodes using
# a forwarded ssh key. The node_copy.sh script will not be able to connect to the nodes otherwise,
# and won't be able to add the master node's ssh key to the root user on the worker nodes.
# Your forwarded key will only exist on the ubuntu account on the worker nodes, but cephadm will try to
# add nodes using the root account..

netdata_dest=$1
netdata_allow=$2

# install the first node
cephadm bootstrap --mon-ip 10.10.11.1 --cluster-network 10.10.11.0/24 | tee /root/ceph-bootstrap-installation.log

# create the ssh key adder script
cat <<EOF > ssh_key_adder.sh
#!/usr/bin/bash
echo $(cat /etc/ceph/ceph.pub) >> /root/.ssh/authorized_keys
EOF
chmod +x ssh_key_adder.sh

# distribute and execute the ssh key adder script
sudo -u ubuntu bash <<'EOF'
cd ~/ceph_utils/node_setup

# create node_list.txt
echo "ubuntu@10.10.11.1" > node_list.txt
echo "ubuntu@10.10.11.2" >> node_list.txt
echo "ubuntu@10.10.11.3" >> node_list.txt
echo "ubuntu@10.10.11.4" >> node_list.txt
echo "ubuntu@10.10.11.5" >> node_list.txt

# add the ceph public key to nodes
./create_ssh_key_adder.sh
./node_copy.sh ssh_key_adder.sh /home/ubuntu/
./node_executor.sh -p sudo /home/ubuntu/ssh_key_adder.sh

# create and copy netdata config file to nodes
./setup-21-create_netdata_stream.conf.sh $netdata_dest $netdata_allow
./node_copy.sh stream.netdata_node.conf /home/ubuntu/stream.conf

EOF

# install netdata on the nodes
./node_executor.sh -p sudo /home/ubuntu/ceph_utils/node_setup/setup-30-install-every-node.sh

# add the nodes to the ceph cluster
ceph orch host add ceph-01 10.10.11.2
ceph orch host add ceph-02 10.10.11.3
ceph orch host add ceph-03 10.10.11.4
ceph orch host add ceph-04 10.10.11.5

