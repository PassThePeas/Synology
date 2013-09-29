#!/bin/sh

. /volume1/pusblic/Scripts/conf/DS411.cnf

mkdir -p "/mnt/DS411/SABnzbd"
mkdir -p "/mnt/DS411/video"

umount /mnt/DS411/SABnzbd
umount /mnt/DS411/video

/bin/mount -t nfs ${DS411_IP}:/volume1/SABnzbd /mnt/DS411/SABnzbd
/bin/mount -t nfs ${DS411_IP}:/volume1/video /mnt/DS411/video

exit 0


