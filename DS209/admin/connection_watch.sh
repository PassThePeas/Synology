#!/opt/bin/bash

# Script that checks for finished downloads in Transmission and
# sends email to a specified user.
# This code placed into public domain

# Requires:
#   GNU mailutils | bsd-mailx (does not work with heirloom-mailx)
#   lockfile-progs
#   transmission-cli

# History:
#----------------------------------------------------------------------------
# Date        | Author <EMail>                  | Description               |
#----------------------------------------------------------------------------
# 15 May 2011 | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX | Creation                  |
# 04 May 2009 | A.Galanin <gaa.nnov AT mail.ru> | Usage moved before locking|
#----------------------------------------------------------------------------

# default configuration options
APPS_TO_WATCH="transmission sabnzbd"
SLEEPTIME=60
DL_STATE=0

FILEPATH="/volume1/public/Scripts"
CONFIG_FILE="$FILEPATH/conf/Connection.cnf"
LOG_PATH="$FILEPATH/../log"
SCRIPT_NAME=`basename $0`
LOG_FILE="$LOG_PATH/${SCRIPT_NAME%.sh}_`date +%Y%m%d_%H%M%S`.log"


#### Options for APP #1 : transmission
HOST=localhost
PORT=9091

DAEMON_NAME=transmission-daemon
DAEMON_OPTIONS=--paused
INFO_GET_NAME=transmission-show

RPC_AUTH=0

PAUSE_transmission () {
	transmission-remote "$HOST":"$PORT" -t all -s
}
RESUME_transmission() {
	transmission-remote "$HOST":"$PORT" -t all -S
}


#### Options for APP #2 : sabnzbd
PAUSE_sabnzbd () {
	sabcli.py  pause > /dev/null 2>&1
}

RESUME_sabnzbd () {
	sabcli.py  resume > /dev/null 2>&1
}


#------------------------------------------------------------------------------

[ -f "$CONFIG_FILE" ] && . "$CONFIG_FILE"

#------------------------------------------------------------------------------


# Remove lock and temporary files, exit with code $1, display message $2
exitAndClean () {
    #kill "$LOCK_PID"
    #lockfile-remove "$LOCK_FILE"
    echo "$2"
    rm -f "$TMP_FILE" "$ALL_FILE"

    logToFile "Exiting with status $1"
    exit "$1"
}

logToFile () {
	laDate=`date +%Y%m%d:%H%M%S`
	echo "$laDate >> $@" >> "$LOG_FILE"
}

pauseOne () {
	TO_EXECUTE=PAUSE_$1
	$TO_EXECUTE
}

resumeOne () {
	TO_EXECUTE=RESUME_$1
	$TO_EXECUTE
}

pauseAll () {
	for app in $APPS_TO_WATCH
	do
		logToFile "Pausing Application : $app"
		pauseOne $app
	done
}


resumeAll () {
	for app in $APPS_TO_WATCH
	do
		logToFile "Resuming Application : $app"
		resumeOne $app
	done
}




# initialization
mkdir -p "$FILEPATH"
mkdir -p "$LOG_PATH"

if [ $# != 0 ]
then
    echo "$0: check for VPN connection and suspend/resume iconfgured APPS accordingly"
    echo "USAGE: $0"
    exit 1
fi

# Check for other instances
ps | grep -w "$0" |grep -v grep | grep -v $$ && exitAndClean 2 "Already running !"



# main
while true
do
	# Check for VPN Connection
	IP_LOC=`GetIPLocalisation.sh`
	if [ "X$IP_LOC" != "XSweden" ]
	then
		logToFile "VPN Connection issue (loc = \"$IP_LOC\") : rechecking"
		IP_LOC=`GetIPLocalisation.sh`
		if [ "X$IP_LOC" != "XSweden" ]
		then
			# Last try based on IP
			myIP=$(CheckIP.sh | cut -d "." -f 1 |grep -E "80|178|188")
			if [ "X$myIP" != "X" ]
			then
				logToFile "VPN Connection seeems OK (IP Check : $myIP.XXXX)"
				if [ $DL_STATE -eq 0 ]
				then
					logToFile "VPN Connection OK : restarting"
					resumeAll
					DL_STATE=1
				fi
			else
				logToFile "VPN Connection issue (loc = \"$IP_LOC\") : pausing downloads"
				pauseAll
				DL_STATE=0
				sleep $SLEEPTIME
				continue
			fi
		else
			if [ $DL_STATE -eq 0 ]
			then
				logToFile "VPN Connection OK : restarting"
				resumeAll
				DL_STATE=1
			else
				logToFile "VPN Connection OK (nothing to do)"
			fi
		fi
	else
		#Connection OK : restarting
		if [ $DL_STATE -eq 0 ]
		then
			resumeAll
			logToFile "VPN Connection back : restarting : DL_STATE = $DL_STATE"
			DL_STATE=1
		fi	
	fi


	sleep $SLEEPTIME
done
exitAndClean 0
