#!/bin/sh

. /volume1/scripts/admin/conf/DS209.cnf

# Faire avec options : all, usb1, usb2, usb3, public
mkdir -p /mnt/DS209/USB3
mkdir -p /mnt/DS209/public
mkdir -p /mnt/DS209/video
mkdir -p /mnt/DS209/public_2
mkdir -p /mnt/DS209/USB2

/bin/umount /mnt/DS209/USB3/
/bin/umount /mnt/DS209/public/
/bin/umount /mnt/DS209/video/
/bin/umount /mnt/DS209/public_2/
/bin/umount /mnt/DS209/USB2/

/bin/mount -t nfs ${DS209_IP}:/volumeUSB3/usbshare /mnt/DS209/USB3/
/bin/mount -t nfs ${DS209_IP}:/volume1/public /mnt/DS209/public/
/bin/mount -t nfs ${DS209_IP}:/volume1/video /mnt/DS209/video/
/bin/mount -t nfs ${DS209_IP}:/volume2/public_2 /mnt/DS209/public_2/
/bin/mount -t nfs ${DS209_IP}:/volumeUSB2/usbshare /mnt/DS209/USB2/


exit 0

