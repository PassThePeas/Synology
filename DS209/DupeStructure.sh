#!/bin/sh

find . -type f | while read file
do
  FileDir=${file%/*}
  mkdir -p "$1/$FileDir"
  touch "$1/$file"
done
