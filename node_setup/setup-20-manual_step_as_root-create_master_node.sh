#!/bin/sh

# this script has to be run manually on the master node, and you have to be able to ssh to the worker nodes using
# a forwarded ssh key. The node_copy.sh script will not be able to connect to the nodes otherwise,
# and won't be able to add the master node's ssh key to the root user on the worker nodes.
# Your forwarded key will only exist on the ubuntu account on the worker nodes, but cephadm will try to
# add nodes using the root account..

# install the first node
cephadm bootstrap --mon-ip 130.238.54.175 --cluster-network 10.10.11.0/24 | tee /root/ceph-bootstrap-installation.log

# create the ssh key adder script
cat <<EOF > ssh_key_adder.sh
#!/usr/bin/bash
echo $(cat /etc/ceph/ceph.pub) >> /root/.ssh/authorized_keys
EOF
chmod +x ssh_key_adder.sh




