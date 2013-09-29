#!/bin/sh

. /volume1/scripts/admin/conf/PCH.cnf

umount /mnt/pch_a210
umount /mnt/pch_a210_usb1
umount /mnt/pch_a110

mount -t cifs //${A210_IP}/share /mnt/pch_a210 -o username=${A210_USERNAME},password=${A210_PASSWORD}
mount -t cifs //${A210_IP}/usb_drive_b-1 /mnt/pch_a210_usb1 -o username=${A210_USERNAME},password=${A210_PASSWORD}
mount -t cifs //${A110_IP}/share /mnt/pch_a110 -o username=${A110_USERNAME},password=${A110_PASSWORD}
