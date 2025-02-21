#!/bin/sh

# this script has to be sourced when you are connected to the node

netdata_dest=$1
netdata_allow=$2

# Check if any of the arguments are empty
if [[ -z "$netdata_dest" ]] || [[ -z "$netdata_allow" ]]; then
    echo "Usage: $0 <netdata_dest> <netdata_allow>"
    echo "  <netdata_dest>   Description of netdata_dest."
    echo "  <netdata_allow>  Description of netdata_allow."
    exit 1
fi

# distribute and execute the ssh key adder script and netdata config file
cd ~/ceph_utils/node_setup

# create node_list.txt
echo "ubuntu@10.10.11.1" > node_list.txt
echo "ubuntu@10.10.11.2" >> node_list.txt
echo "ubuntu@10.10.11.3" >> node_list.txt
echo "ubuntu@10.10.11.4" >> node_list.txt
echo "ubuntu@10.10.11.5" >> node_list.txt

# add the ceph public key to nodes
./node_copy.sh ssh_key_adder.sh /home/ubuntu/
./node_executor.sh -p sudo /home/ubuntu/ssh_key_adder.sh

# create and copy netdata config file to nodes
./setup-supplemental-22-create_netdata_stream.conf.sh $netdata_dest $netdata_allow
./node_copy.sh stream.netdata_node.conf /home/ubuntu/stream.conf

# install netdata on the nodes
./node_executor.sh -p /home/ubuntu/ceph_utils/node_setup/setup-supplemental-30-install-every-node.sh

