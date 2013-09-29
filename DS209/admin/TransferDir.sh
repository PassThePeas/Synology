#!/opt/bin/bash

. /volume1/pusblic/Scripts/conf/PCH.cnf
. /volume1/pusblic/Scripts/conf/DS411.cnf


# Variables
LFTP_PCH_CONNECT_A210_USB="ftp://${A210_USERNAME}:${A210_PASSWORD}@${A210_IP}/USB_DRIVE_B-1/PCH_A210/SAB_AUTO_TMP"
LFTP_PCH_CONNECT_A210_HDD="ftp://${A210_USERNAME}:${A210_PASSWORD}@${A210_IP}/SATA_DISK/SAB_AUTO_TMP"
LFTP_PCH_CONNECT_DS411="ftp://${DS411_USERNAME_USER1}:${DS411_PASSWORD_USER1}@${DS411_IP}/SABnzbd/Import_SAB_DS209"
LFTP_PCH_CONNECT_A110_HDD="ftp://${A110_USER_FTP}:${A110_PASSWORD_FTP}@${A110_IP}/SAB_AUTO_TMP"
LFTP_PCH_CONNECT="ftp://${A210_USERNAME}:${A210_PASSWORD}@${A210_IP}/USB_DRIVE_B-1/PCH_A210/SAB_AUTO_TMP"
LFTP_MIRROR_CMD="mirror -R"

# Files
LOG_PATH="/volume1/public/Scripts/log/"
SCRIPT_NAME=`basename $0`
LOG_FILE="$LOG_PATH/${SCRIPT_NAME%.sh}_`date +%Y%m%d_%H%M%S`.log"
REPORT_PATH="/volume1/public/Scripts/reports"
LFTP_TMP_SCRIPT_PATH="/volume1/public/Scripts/tmp_scripts/lftp_cmd_$$"

logToFile () {
        laDate=`date +%Y%m%d:%H%M%S`
        echo "$laDate >> $@" >> "$LOG_FILE"
}


## MAIN
# log start
logToFile "Starting ..."
#logToFile "Id is = $(id)"


LFTP_PCH_CONNECT="$LFTP_PCH_CONNECT_DS411"

for i in *
	do
	if [ -d "$i" ]
	then
		LFTP_TMP_SCRIPT_PATH="/volume1/public/Scripts/tmp_scripts/lftp_cmd_$i"
		# Build lftp script file
		rm -f "$LFTP_TMP_SCRIPT_PATH"
		cd "$i"
		echo "open $LFTP_PCH_CONNECT" >> "$LFTP_TMP_SCRIPT_PATH"
		if [ "X$1" != "X" ]
		then
			echo "cd \"$1\"" >>  "$LFTP_TMP_SCRIPT_PATH"
		fi
		echo "mkdir \"$i\"" >> "$LFTP_TMP_SCRIPT_PATH"
		echo "cd \"$i\"" >> "$LFTP_TMP_SCRIPT_PATH"
		echo "$LFTP_MIRROR_CMD" >> "$LFTP_TMP_SCRIPT_PATH"
		/opt/bin/lftp -f "$LFTP_TMP_SCRIPT_PATH"
		logToFile "Moved"
		
		# Build report
		echo "$i " >> "${REPORT_PATH}/${i}.report"
		laDate=`date +%Y%m%d:%H%M%S`
		echo "$laDate -- File Moved to $DESTINATION" >> "${REPORT_PATH}/${i}.report"
		cd ..
	fi
done

