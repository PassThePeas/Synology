#!/bin/sh

curl -L -s --max-time 40 http://www.ipligence.com/geolocation | grep Country | sed 's/.*Country: //g' |sed 's/<br>.*//g'

