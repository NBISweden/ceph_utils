#!/bin/bash

cat <<EOF > ssh_key_adder.sh
#!/usr/bin/bash
echo $(cat /etc/ceph/ceph.pub) >> /root/.ssh/authorized_keys
EOF
chmod +x ssh_key_adder.sh
