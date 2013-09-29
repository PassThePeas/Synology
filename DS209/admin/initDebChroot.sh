#!/bin/ash

mount -o bind /volume1/@local/debian /opt/debian
mount -o bind /dev /opt/debian/chrootgnuspe/dev
mount -o bind /proc /opt/debian/chrootgnuspe/proc
mount -o bind /usr/local/powerpc-linux-gnuspe /opt/debian/chrootgnuspe/usr/local/powerpc-linux-gnuspe

mount -o bind /volume1/public/Java/YAMJ/ /opt/debian/chrootgnuspe/root/YAMJ
mount -o bind /volume1/public/Scripts/COMPIL/MEDIA_INFO/MediaInfo_CLI_0.7.43_GNU_FromSource/MediaInfo/Project/GNU/CLI /opt/debian/chrootgnuspe/root/MediaInfo_CLI

mount -o bind /volume1/video/ /opt/debian/chrootgnuspe/root/Libraries/ds209_video
mount -o bind /volume1/public/ /opt/debian/chrootgnuspe/root/ds209_public

chroot /opt/debian/chrootgnuspe /bin/bash
