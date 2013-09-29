#!/bin/sh

. /volume1/pusblic/Scripts/conf/Sickbeard.cnf


curl -L -s --max-time 10 "http://${SICKBEARD_HOST}:${SICKBEARD_PORT}/api/${SICKBEARD_API_KEY}/?cmd=$1"


