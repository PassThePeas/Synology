#!/opt/bin/bash

DIR=$1
CLI_DIR=/volume1/public/Scripts/FLICKR/RELEASE_0_2_8/Tools
CLI=PhlickrUploader_cli.php
LOG_FILE=`basename "$DIR"`

# $CLI_DIR/$CLI -c -p20 -d "$DIR" | tee -a "$CLI_DIR/logs/$LOG_FILE.log"
$CLI_DIR/$CLI -c -d "$DIR" | tee -a "$CLI_DIR/logs/$LOG_FILE.log"
#./$CLI -c -p20 -d "$DIR" | tee -a $CLI_DIR/logs/`basename "$DIR"`.log

