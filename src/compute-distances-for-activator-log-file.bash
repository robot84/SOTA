#!/bin/bash
#
#

# some temp file
TMP_FILE=$(mktemp)

# without this timer we overload distance calculating server and doesn't get a response from it
SLEEP_TIMER=3

# show RS report?
REPORT_SHOW=false

cd $(dirname $0)
. load_config_file.bash

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

cd $(dirname $0)

touch $TMP_FILE
if [ ! -f $TMP_FILE ]
then
echo "$0: Error: Can not create file $TMP_FILE"
exit 1
fi

if [ ! -w $TMP_FILE ]
then
echo "$0: Error: Can not write to file $TMP_FILE"
exit 1
fi

if [ ! -f "$SUMMITS_QTH_LOCATORS_FILE" ]
then
echo "$0: Error: Can not open file $SUMMITS_QTH_LOCATORS_FILE Check if file exists"
exit 2
fi

if [ ! -r "$SUMMITS_QTH_LOCATORS_FILE" ]
then
echo "$0: Error: Can not open file $SUMMITS_QTH_LOCATORS_FILE for reading"
exit 2
fi

if [ ! -f $CHASERS_QTH_LOCATORS_FILE ]
then
echo "$0: Error: Can not open file $CHASERS_QTH_LOCATORS_FILE Check if file exists"
exit 3
fi

if [ ! -r $CHASERS_QTH_LOCATORS_FILE ]
then
echo "$0: Error: Can not open file $CHASERS_QTH_LOCATORS_FILE for reading"
exit 3
fi


cat - | awk -F, ' {print $3,$4,$5,$6,$8,$10}' > $TMP_FILE

echo -e "Date\t|  Time\t|QSO from \t| with call\t | is [km] |"
while read SUMMIT D4 D5 D6 CALLSIGN D10;
do
SUMMIT_QTH_LOCATOR=`cat "${SUMMITS_QTH_LOCATORS_FILE}" | grep "$SUMMIT " | awk '{print $2}'`
CHASERS_QTH_LOCATOR=`cat "${CHASERS_QTH_LOCATORS_FILE}" | grep "$CALLSIGN " | awk '{print $2}'`

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
