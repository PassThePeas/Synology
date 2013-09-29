#!/bin/sh

. /volume1/pusblic/Scripts/conf/PCH.cnf

umount /mnt/pch_a210
umount /mnt/pch_a210_usb1
umount /mnt/pch_a110

mount -t nfs ${A210_IP}:/share /mnt/pch_a210
mount -t nfs ${A210_IP}:/USB_DRIVE_B-1 /mnt/pch_a210_usb1
mount -t nfs ${A110_IP}:/share /mnt/pch_a110


