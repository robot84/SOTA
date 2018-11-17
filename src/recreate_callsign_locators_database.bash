#!/bin/bash
#
#

DEBUG_ENABLED=no

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
        echo "Use this script if wants to recreate callsign_locators database (.dat file)"
        echo "It works off-line in contrast to get-callsign-info-page.bash,"
        echo "which works completly  on-line."
        echo
        echo "If you see on output something like that:"
        echo -e "SP9ABC ??????\t it means there is no QTH Locator information for this user"
        echo "\t\t\tIn this case you must obtain it from other sources than qrz.com."
		echo
		echo "\t\t--version\tprint version info and exit"
        exit 1
      ;;
  --version)
	  echo "${0##*/} $APP_VER"
	  echo "Copyright (C) 2018 SO9ARC"
	  echo "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>."
	  echo "This is free software: you are free to change and redistribute it. "
	  echo "There is NO WARRANTY, to the extent permitted by law."
	  echo
	  echo "Written by Robert Zabkiewicz SO9ARC."
	  exit
	  ;;
  *)
        echo "$0: invalid option -- '$1'"
        echo "Try '$0 --help' for more information."
        exit
      ;;
    esac
  done
}


function print_locator_not_found_reason() {
local log_file="$1"
grep -q "Your Search by Callsign found no results" "$log_file"  && echo "Callsign doesn't exist in http://qrz.com database." && return
grep -q "Service limit exceeded: Too many lookups" "$log_file"  && ( echo "Too many lookups today for http://qrz.com database. Try tommorow."; rm "$log_file"; ) && return
echo "User didn't provided his QTH Locator on http://qrz.com"

}


function parse_callsign_files() {
  local log_file
  cd "${DB_DIRECTORY}"
  for log_file in *.log
  do
    CALLSIGN=`echo $log_file | awk -F  "." ' {print $1}'`
    # alternate pattern to use if original fail for some records
    # SQUARE=`cat $log_file |grep "Grid Square" | grep -o "Grid Square [A-Za-z][A-Za-z][0-9][0-9][A-Za-z][A-Za-z]" | awk '{print $3}'`
    SQUARE=$(cat "$log_file" |grep "Square" | grep -oE "Square[[:space:]]+[A-Za-z][A-Za-z][0-9][0-9][A-Za-z][A-Za-z]" | awk '{print $2}')
    if [ -z "$SQUARE" ]
    then
      echo  -n "$CALLSIGN ?????? "
	  print_locator_not_found_reason "$log_file"
    else
      echo "$CALLSIGN $SQUARE" >> "${SCRIPT_DIR}/$CHASERS_QTH_LOCATORS_FILE"
    fi
  done
  
  TMP_FILE=$(mktemp)
  cp "${SCRIPT_DIR}/$CHASERS_QTH_LOCATORS_FILE" "$TMP_FILE"
  f_log_msg "${SCRIPT_DIR}/$LOG_FILE" "Notice: Recreating database. Backed up chasers_locators.dat file as $TMP_FILE"
  cat "$TMP_FILE" | grep -vE "\?{6}"| sort | uniq > "${SCRIPT_DIR}/$CHASERS_QTH_LOCATORS_FILE"
#  echo TMP FILE $TMP_FILE
}



############################################## PROGRAM ENTRY POINT #############################

SCRIPT_DIR="$(dirname $(readlink -e $0))"
BASE_DIR="$(dirname \"$SCRIPT_NAME\")"
cd "$SCRIPT_DIR"
. load_config_file.bash
. f_log_msg
load_config_file
parse_parameters $@
parse_callsign_files
exit 0
