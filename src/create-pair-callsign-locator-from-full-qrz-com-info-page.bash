#!/bin/bash
#
# writes to stdout pairs: chaser_callsign his_qth_locator
# one pair by line
#
# Example of output:
# 3Z9AM JO90xa
# HF50BRP ??????
# HF9D JO90ki
# OK2BTC JN99jo
#
# ?????? means that there is no locator info in database
# try to obtain it manually from other source (your friends, internet)
#

STARTING_DIR=`pwd`
cd $(dirname $0)
source ../resources/config.cfg

cd "${DB_DIRECTORY}"
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
# alternate pattern is commented:
# maybe if primary will fail for a record, this one can do it
# html2text $VAR |grep "Grid Square" | grep -o "Grid Square [A-Za-z][A-Za-z][0-9][0-9][A-Za-z][A-Za-z]" | awk '{print $3}'

done
cd "$STARTING_DIR"
