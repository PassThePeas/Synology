#!/opt/bin/bash


mediainfo "$*" | grep -E "Text|Video|Audio|Language"


