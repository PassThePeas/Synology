#!/bin/sh

filename="$*"
fileext=${filename##*.}

if [ "X$fileext" = "Xmkv" ]
then
	mkvmerge -I "$filename"
else
	ffmpeg -i "$*"  -info 
fi

