# Installing the Ceph cluster

This assumes that you have just deployed your nodes with MAAS, supplying the `cloud-init-user-data.yaml` file in the deploy step. This will install most dependencies and tools needed by Ceph.

Start by connecting to the node that will be the first Ceph master node, and make sure you forward your ssh key so that you can ssh to the remaining nodes from this node.

```bash
# connect to the master node
ssh -A ubuntu@<master node ip>

# once connected, make sure you can ssh to the remaining nodes using the forwarded ssh key
ssh <worker node ip>
```

Ok, then you are ready to run the scripts to set up the cluster.

```bash
# install ceph on the master node, make sure to save the admin password in the text printed to the screen.
# It is also saved to `/root/ceph-bootstrap-installation.log` if you were to miss it.
cd ~/ceph_utils/node_setup
sudo ./setup-20-manual_step_as_root-create_master_node.sh

# then you have to source the next file as the ubuntu user, otherwise the forwarded ssh key will not be available to the script,
# and supplying the ip of the netdata master node, as well as the ip range the master should accept data from.
# Ex.
# source setup-21-manual_step_source_as_user-copy_files_to_nodes.sh 130.238.500.100 130.238.500.*
source setup-21-manual_step_source_as_user-copy_files_to_nodes.sh <master netdata node ip> <ip range of netdata nodes>

# now is a good time to copy the `stream.netdata_master.conf` to your netdata master node and restart it.
# the config file contains the newly created api key that the worker nodes will be using, and the master must have the same.

# then you are ready to add the remaining nodes to the cluster
sudo ./setup-23-manual_step_as_root-add_nodes.sh

# create a self signed ssl cert to add to the rgw service during the installation in the Ceph dashboard
sudo ./setup-24-manual_step_as_root-generate_ssl_cert.sh
sudo cat ceph.pem
```

After this, you should be able to connect to the Ceph dashboard on `https://<ceph master node ip>:8443` and login using the 




