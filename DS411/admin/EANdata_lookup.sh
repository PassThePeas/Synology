#!/bin/sh

curl -L -s --max-time 40 http://eandata.com/lookup.php?code="$1" | grep "<title>" | sed 's/.*<title>//g' |sed 's/<\/title>.*//g' |sed "s#[0-9]*$1 \- ##g"


