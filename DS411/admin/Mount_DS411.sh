#!/bin/sh

. /volume1/scripts/admin/conf/DS411.cnf

mkdir -p "/mnt/DS411/SABnzbd"

umount /mnt/DS411/SABnzbd


/bin/mount -t nfs ${DS411_IP}:/volume1/SABnzbd /mnt/DS411/SABnzbd

exit 0


