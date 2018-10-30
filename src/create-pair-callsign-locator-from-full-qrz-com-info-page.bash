#!/bin/bash
cd database
for VAR in *.log
do
CALLSIGN=`echo $VAR | awk -F  "." ' {print $1}'`
echo -n "$CALLSIGN "
SQUARE=`html2text $VAR |grep "Square" | grep -o "Square [A-Za-z][A-Za-z][0-9][0-9][A-Za-z][A-Za-z]" | awk '{print $2}'`
if [ -z "$SQUARE" ]
then
echo "??????"
else
echo "$SQUARE"
fi
# html2text $VAR |grep "Grid Square" | grep -o "Grid Square [A-Za-z][A-Za-z][0-9][0-9][A-Za-z][A-Za-z]" | awk '{print $3}'
done
cd -
