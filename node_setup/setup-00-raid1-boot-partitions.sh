#!/bin/sh

# add entry for 2nd partition
efibootmgr -c -L "ubuntu1" -d /dev/nvme1n1 -p 1 -l "\EFI\ubuntu\shimx64.efi"

# set boot order to the boot partitions before network
# Find the IDs for "ubuntu" entries and store them in a variable
ubuntu_ids=$(efibootmgr | grep 'ubuntu' | awk '{print substr($1, 5, 4)}' | tr '\n' ',' | sed 's/,$//')

# Get the current boot order and store it in a variable
current_order=$(efibootmgr | grep "^BootOrder:" | cut -d ' ' -f 2)

# Create the new boot order by prepending the "ubuntu" IDs
new_boot_order="${ubuntu_ids},${current_order}"

# Remove duplicates
cleaned_order=$(echo "$new_boot_order" | awk 'BEGIN{RS=ORS=","} !seen[$1]++' | head -c -1)

# Trim the trailing comma
cleaned_order="${cleaned_order%,}"

# Use the new boot order in the efibootmgr command
efibootmgr -o "$cleaned_order"

# create raid volume with 2nd partition only
yes | mdadm --create /dev/md100 --level 1 --raid-disks 2 --metadata 1.0 -f /dev/nvme1n1p1 missing

# create fs
mkfs.fat -F32 /dev/md100

# copy content to raid
mkdir /tmp/RAID; mount /dev/md100 /tmp/RAID
rsync -av --progress /boot/efi/ /tmp/RAID/

# add 1st partition to raid
umount /dev/nvme0n1p1
mdadm --manage /dev/md100 --add /dev/nvme0n1p1

# change boot to raid partition and make it not automount in fstab
sed -i 's|/dev/disk/by-uuid/[^\s]\+ /boot/efi vfat defaults 0 1|/dev/md100 /boot/efi vfat umask=0077,noauto,defaults 0 0|' /etc/fstab

# add to mdadm.conf and make it not automount
mdadm --detail --scan | grep 100 >> /etc/mdadm/mdadm.conf
sed -i 's|/dev/md100|<ignore>|' /etc/mdadm/mdadm.conf

# make it sync on boot
uuid=$(grep '<ignore>' /etc/mdadm/mdadm.conf | awk -F'UUID=' '{print $2}')
cat > /etc/systemd/system/mdadm_esp.service <<EOF
[Unit]
Description=Resync /boot/efi RAID
DefaultDependencies=no
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/sbin/mdadm -A /dev/md100 --uuid=$uuid --update=resync
ExecStart=/bin/mount /boot/efi
RemainAfterExit=yes

[Install]
WantedBy=sysinit.target
EOF

umount /tmp/RAID/
mount /boot/efi

systemctl enable mdadm_esp.service
update-initramfs -u

