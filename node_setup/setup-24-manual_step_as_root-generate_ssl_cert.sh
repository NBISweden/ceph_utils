#!/bin/sh

# generate cert
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout ceph.key -out ceph.crt -subj "/C=SE/ST=State/L=City/O=Organization/OU=Unit/CN=ceph"

# concatinate to pem
#install -m 600 /dev/null ceph.pem
#cat ceph.key ceph.crt >> ceph.pem
cat ceph.crt
