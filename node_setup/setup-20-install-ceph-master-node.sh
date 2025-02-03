#!/bin/sh

# install the first node
cephadm bootstrap --mon-ip 130.238.54.175 --cluster-network 10.10.11.0/24 > /root/ceph-bootstrap-installation.log
