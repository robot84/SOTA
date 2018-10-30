#!/bin/bash
#
# (c) SO9ARC Robert Zabkiewicz 2018
#
# VER=0.1.2
#$SLEEP_TIME - getting better performance against 500 Too Many Requests server's response. In seconds.
# Revision History:
# 0.1.2 we don't accept stroked callsigns like W7ABC/x, etc
SLEEP_TIME=2
if [ "$#" -ne 1 ]
then 
     echo "Usage:"
	 echo "$0 <callsign>"
exit
fi

CALLSIGN="$1"

if [[ "$CALLSIGN" =~ [A-Za-z0-9]*/[A-Za-z0-9][A-Za-z0-9]* ]]
then
echo "Unacceptable (stroked) callsign $CALLSIGN. Exiting..."
exit
fi


if [ -d ./database ]
then
echo ""
else
	mkdir ./database
fi

if [ -e database/$CALLSIGN.log ]
then
	echo "Information about callsing $CALLSIGN already obtained. Nothing to do."
	echo ""
else
echo "Getting info about $CALLSIGN..."
curl -s --cookie qrz.cookie.txt -X POST -F "tquery=$CALLSIGN" -F "mode=callsign" -F "id=topcall" -e "https://www.qrz.com/lookup" -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36' "https://www.qrz.com/lookup" | html2text > database/$CALLSIGN.log || echo "ERROR"
sleep $SLEEP_TIME
fi
