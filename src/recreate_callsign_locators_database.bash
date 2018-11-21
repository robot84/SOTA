#!/bin/bash
#
#

DEBUG_ENABLED=no
LOCATOR_REGEX_PATTERN="[A-Za-z][A-Za-z][0-9][0-9][A-Za-z][A-Za-z]"

function parse_parameters() {
  
  POSITIONAL=()
  while [[ $# -gt 0 ]]
  do
    key="$1"
    
    case $key in
      -h|--help)
        echo ""
        echo "Usage: ${0##*/} "
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
	  print_version_info
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



function compact_callsign_dot_log_file() {
local log_file="$1"
local CALLSIGN="$2"
local square="$3"

if [ ! -z "$square" ]
then
echo "Square $square" > "$tmp_dir/$CALLSIGN.log"
else
grep -q "Your Search by Callsign found no results" "$log_file"  && ( echo "Your Search by Callsign found no results" > "$tmp_dir/$CALLSIGN.log"; return 0 ) && return
grep -q "Service limit exceeded: Too many lookups" "$log_file"  &&  ( rm "$log_file"; ) && return
echo Square > "$tmp_dir/$CALLSIGN.log"
fi
}


function set_CALLSIGN_var() {
local log_file="$1"
local log_file_basename=${log_file##*/}
CALLSIGN=${log_file_basename%.log}
}


function parse_callsign_files() {
  for log_file in "${DB_DIRECTORY}"/*.log
  do
  
  set_CALLSIGN_var "$log_file"
    SQUARE=$(cat "$log_file" |grep "Square" | grep -oE "Square[[:space:]]+$LOCATOR_REGEX_PATTERN" | awk '{print $2}')
    if [ -z "$SQUARE" ]
    then
      echo  -n "."
	  compact_callsign_dot_log_file "$log_file" "$CALLSIGN" "$SQUARE"
    else
      echo  -n "."
      echo "$CALLSIGN $SQUARE" >> "$CHASERS_QTH_LOCATORS_FILE"
	  compact_callsign_dot_log_file "$log_file" "$CALLSIGN" "$SQUARE"
    fi
  done
 echo  ""

  TMP_FILE=$(mktemp)
  cp "$CHASERS_QTH_LOCATORS_FILE" "$TMP_FILE"
  f_log_msg "$ERROR_LOG_FILE" "Notice: Recreating database. Backed up chasers_locators.dat file as $TMP_FILE"
  cat "$TMP_FILE" | grep -vE "\?{6}"| sort | uniq > "$CHASERS_QTH_LOCATORS_FILE" && echo Success.
}



############################################## PROGRAM ENTRY POINT #############################
SCRIPT_DIR="$(dirname $(readlink -e $0))"
BASE_DIR="$(dirname \"$SCRIPT_NAME\")"
. "$SCRIPT_DIR/load_config_file.bash"
load_config_file "$SCRIPT_DIR"
parse_parameters $@
tmp_dir=$(mktemp -d)
backup_dir=$(mktemp -d tmp.backup_database.XXXXXXXX)
parse_callsign_files
mv -t "$backup_dir" "$DB_DIRECTORY"/* 
mv -t "$DB_DIRECTORY" "$tmp_dir"/* 
rmdir "$tmp_dir"
exit 0
