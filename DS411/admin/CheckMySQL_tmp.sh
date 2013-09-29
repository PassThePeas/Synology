#!/bin/sh


OCC_TMP=`df -h | grep tmp |sed -r "s/ {1,}/@/g" | awk -F@ '{print$5}'`
#echo "/tmp occupé à : $OCC_TMP"

if [ "X$OCC_TMP" = "X100%" ]
then
	echo "`date +%Y%m%d-%H:%M` >> /tmp FULL - Relaunching MySQL" |tee -a  /volume1/@appstore/newznab/logs/autorelaunch_mysql.log
	# if yes : restart
	/usr/syno/etc/rc.d/S21mysql.sh restart
fi



