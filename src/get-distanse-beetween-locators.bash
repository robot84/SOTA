#!/bin/bash
#
#
#
QTH_LOCATOR_PATTERN="[A-Za-z][A-Za-z][0-9][0-9][A-Za-z][A-Za-z]"

if [ "$#" -ne 2 ]
then
    echo "Usage:"
	echo "$0 <QTHlocator1> <QTHlocator2>"
  exit
fi

if [[ "$1" =~ $QTH_LOCATOR_PATTERN ]] && [[ "$2" =~ $QTH_LOCATOR_PATTERN ]]
then
	curl -s -X POST --data "mygrid=$1&fagrid=$2" https://www.chris.org/cgi-bin/showdis > qth.tmp
	cat qth.tmp | grep "Distance between"
else
	echo "QTHlocator must be 6 characters length and in format AB01CD"
fi
#| awk '{print $7,$8
#Distance between JO80WA & JO90XA is 148.84 km (
