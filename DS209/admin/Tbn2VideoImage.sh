#!/bin/sh

find . -name "*.tbn" | while read file
do
#  echo "Fichier : $file"
  unext_file=${file%.*}
  videoImage_file=${unext_file}.videoimage.jpg
#  echo "Fichier dest : $videoImage_file"
  cp -p "$file" "$videoImage_file"
done



