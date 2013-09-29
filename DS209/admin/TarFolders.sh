#!/bin/sh

DELETE_FOLDERS=0

if [ "X$1" = "X-d" ]
then
	DELETE_FOLDERS=1
fi

find . -type d -maxdepth 1 ! -name "."  | while read directory
do
	tar cvf ${directory}.tar ${directory}
	gzip ${directory}.tar
	if [ $DELETE_FOLDERS -eq 1 ]
	then
		rm -Rf ${directory}
	fi
done
