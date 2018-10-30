#!/bin/bash
#
# Version 0.0.2
# usage: cat activator-log.csv | ./this_script [-r] | tee distances.txt

# some temp file
TMP_FILE="/tmp/.activator.tmp"

# without this timer we overload distance calculating server and doesn't get a response from it
SLEEP_TIMER=3

# show RS report?
REPORT_SHOW=false


if [ "$#" = 1 ] && [ "$1" = "-r" ]
then
REPORT_SHOW=true
fi

if [ "$#" -ge 1 ] && [ "$1" != "-r" ]
then
echo
echo "Usage:  cat qso-log.csv | $0 [-r] | tee my-qso-distances.txt"
echo
echo -e "-r\t\tShow RS SENT/RCVD report."
echo
echo -e "qso-log.csv\tdownload it from http://sotadata.org.uk/"
echo -e "\t\tTo do this, navigate via menu:"
echo -e "\t\tView Results->My results->My Activator Log"
echo -e "\t\tAt the bottom of this page click 'Download complete log'"
echo
exit 127
fi

cat - | awk -F, ' {print $3,$4,$5,$6,$8,$10}' > $TMP_FILE

echo -e "Date\t|  Time\t|QSO from \t| with call\t | is [km] |"
while read SUMMIT D4 D5 D6 CALLSIGN D10;
do
SUMMIT_QTH_LOCATORS_FILE="SP-BZ-QTH-Locators.txt"
CHASERS_QTH_LOCATORS_FILE="SP-chasers-locators.txt"
SUMMIT_QTH_LOCATOR=`cat ${SUMMIT_QTH_LOCATORS_FILE} | grep "$SUMMIT" | awk '{print $2}'`
CHASERS_QTH_LOCATOR=`cat ${CHASERS_QTH_LOCATORS_FILE} | grep "$CALLSIGN" | awk '{print $2}'`


if [ -z $CHASERS_QTH_LOCATOR ]
then
#	echo "No QTH Locator found for callsign $CALLSIGN"
	echo -n
else
DISTANCE=`./get-distanse-beetween-locators.bash $SUMMIT_QTH_LOCATOR $CHASERS_QTH_LOCATOR | awk '{print $7,$8}'`
echo -en "$D4 $D5 $SUMMIT\t $CALLSIGN\t\t $DISTANCE"
[ "$REPORT_SHOW" = "true" ] && echo " $D10" || echo ""
	sleep $SLEEP_TIMER
fi
done <$TMP_FILE
rm $TMP_FILE
