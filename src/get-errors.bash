#!/bin/bash
INPUT_FILE=sota.tmp
cat - | awk -F, ' {print $3,$4,$5,$6,$8,$10}' > $INPUT_FILE

while read SUMMIT D4 D5 D6 CALLSIGN D10;
do
SUMMIT_QTH=`cat SP-BZ-QTH-Locators.txt | grep "$SUMMIT" | awk '{print $2}'`
CALLSIGN_QTH=`cat SP-chasers-locators.txt | grep "$CALLSIGN" | awk '{print $2}'`


if [[ -z $CALLSIGN_QTH ]]
then
echo "No callsign $CALLSIGN in database"
#echo  "Error when processing QSO from $SUMMIT ($SUMMIT_QTH) with $CALLSIGN ($CALLSIGN_QTH) $D4 $D5 $D6 Notes: $D10"
fi 

if [[ $CALLSIGN_QTH = "??????" ]];
then
echo "Callsign $CALLSIGN has no QTH Locator in database"
fi

done <$INPUT_FILE
rm $INPUT_FILE
