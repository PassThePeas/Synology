#!/bin/sh

. /volume1/scripts/admin/conf/USB_STATION.cnf

umount /mnt/usb_station

mount -t cifs //192.168.1.80/usbshare1 /mnt/usb_station -o username=root,password=${USB_STATION_PASSWORD}
