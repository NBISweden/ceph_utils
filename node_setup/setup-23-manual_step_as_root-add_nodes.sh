#!/bin/sh

# add the nodes to the ceph cluster
ceph orch host add ceph-01 10.10.11.2
ceph orch host add ceph-02 10.10.11.3
ceph orch host add ceph-03 10.10.11.4
ceph orch host add ceph-04 10.10.11.5
