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

function load_config_file() {
. load_config_file.bash
}

function parse_parameters() {

POSITIONAL=()
	while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
	-h|--help)
	echo ""
	echo "Usage:"
	echo "${0##*/} "
	echo "Write to file QTH locators for all callsigns obtained by get-callsign-info-page.bash"
	echo "Write to stdout callsigns for whom we cannot specify QTH locator."
	echo
	exit 1
	;;
	*)
	echo "$0: invalid option -- '$1'"
	echo "Try '$0 --help' for more information."
	exit
	;;
	esac
	done
}


function parse_callsign_files() {
DIR_BEFORE_CD=$(pwd)
cd "$(dirname $0)/${DB_DIRECTORY}"
pwd
for VAR in *.log
do
CALLSIGN=`echo $VAR | awk -F  "." ' {print $1}'`
# alternate pattern to use if original fail for some records
# SQUARE=`html2text $VAR |grep "Grid Square" | grep -o "Grid Square [A-Za-z][A-Za-z][0-9][0-9][A-Za-z][A-Za-z]" | awk '{print $3}'`
SQUARE=`html2text $VAR |grep "Square" | grep -o "Square [A-Za-z][A-Za-z][0-9][0-9][A-Za-z][A-Za-z]" | awk '{print $2}'`
if [ -z "$SQUARE" ]
then
echo "$CALLSIGN ??????" 
else
echo "$CALLSIGN $SQUARE" >> "${DIR_BEFORE_CD}/$CHASERS_QTH_LOCATORS_FILE"
# echo File: "${DIR_BEFORE_CD}/$CHASERS_QTH_LOCATORS_FILE"
fi

done
cd "$STARTING_DIR"
}


load_config_file
parse_parameters $@
parse_callsign_files
