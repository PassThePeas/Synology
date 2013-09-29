#!/bin/sh

. /volume1/scripts/admin/conf/PCH.cnf

mkdir -p /mnt/A210
mkdir -p /mnt/A210_USB
mkdir -p /mnt/A110

umount /mnt/A210
umount /mnt/A210_USB
umount /mnt/A110

mount -t nfs ${A110_IP}:/share /mnt/A110
mount -t nfs ${A210_IP}:/share /mnt/A210
mount -t nfs ${A210_IP}:/USB_DRIVE_B-1 /mnt/A210_USB


