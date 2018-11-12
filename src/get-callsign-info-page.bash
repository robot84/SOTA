#!/bin/bash
#
# (c) SO9ARC Robert Zabkiewicz 2018
#
#$SLEEP_TIME - getting better performance against 500 Too Many Requests server's response. In seconds.
#

APP_VER=0.4
SLEEP_TIME=2
ERROR__NO_CALLSIGN_PASSED_TO_SCRIPT=1
ERROR__CALLSIGN_DOESNT_MATCH_PATTERN=2
ERROR__COMMUNICATION_WITH_QRZ_COM_SERVER_FAILED=3
ERROR__CANNOT_OPEN_COOKIE_FILE_FOR_READING=5
ERROR__INVALID_OR_EXPIRED_COOKIE_FILE=6
SP_CHASERS_FILE=""
INPUT_FILE_IS_ACTIVATOR_LOG=no
INPUT_FILE_IS_CHASER_LOG=no


function open_cookie_file() {
  if [ ! -r ${COOKIE_FILENAME} ]
  then
    echo $COOKIE_FILENAME
    echo "Error: Cannot open cookie file for read."
    echo "Check if cookie file ${COOKIE_FILENAME} exists
    and you have permissions for reading it."
    
    f_log_msg "$LOG_FILE" "Error: no cookie file available. Cannot login to http://qrz.com/"
    exit $ERROR__CANNOT_OPEN_COOKIE_FILE_FOR_READING
  fi
}

function parse_parameters() {
  if [ "$#" -lt 1 ]
  then
    echo "$0: Mandatory argument ommited."
    echo "Try '$0 --help' for more information."
    f_log_msg "$LOG_FILE" ${!ERROR__NO_CALLSIGN_PASSED_TO_SCRIPT@}
    exit $ERROR__NO_CALLSIGN_PASSED_TO_SCRIPT
  fi
  
  POSITIONAL=()
  while [[ $# -gt 0 ]]
  do
    key="$1"
    
    case $key in
      -h|--help)
        echo ""
        echo "Usage:"
        echo "${0##*/} [-a filename] [-c filename] [-p filename] [callsign]"
        echo "Searching QTH Locators for callsigns."
        echo
		echo "You can pass one callsign as a parameter or list of callsigns in file with -f option."
        echo -e "  -p, --plain-log\t\t file with callsign list. In format: One callsign per line."
		echo -e "\t\t\t\t Only callsigns without strokes (e.g. /M /P /9 OM/ OK/ etc) are accepted."
		echo -e "  -a, --activator-log\t\t input file is .csv activator log downloaded from sotadata.org.uk"
		echo -e "  -c, --chaser-log\t\t input file is .csv chaser log downloaded from sotadata.org.uk"
		echo
		echo -e "      --help\t\t\t display this help and exit"
		echo -e "      --version\t\t\t output version information and exit"
        exit $ERROR__NO_CALLSIGN_PASSED_TO_SCRIPT
      ;;
      -p|--plain-log)
        SP_CHASERS_FILE="$2"
        shift
        shift
      ;;
       -a|--activator-log)
		INPUT_FILE_IS_ACTIVATOR_LOG=yes
        SP_CHASERS_FILE="$2"
        shift
        shift
      ;;
       -c|--chaser-log)
		INPUT_FILE_IS_CHASER_LOG=yes
        SP_CHASERS_FILE="$2"
        shift
        shift
      ;;

     --version)
	  echo "${0##*/} $APP_VER"
        echo "Copyright (C) 2018 SO9ARC"
        echo "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>."
        echo "This is free software: you are free to change and redistribute it. "
        echo "There is NO WARRANTY, to the extent permitted by law."
        exit
      ;;
      -*)
        echo "$0: invalid option -- '$1'"
        echo "Try '$0 --help' for more information."
        exit
      ;;
      *)
        POSITIONAL+=("$1") # save it in an array for later
        shift
      ;;
    esac
  done
  set -- "${POSITIONAL[@]}" # restore positional parameters
  
[ -z "$SP_CHASERS_FILE" ] && CALLSIGN="${POSITIONAL[0]}" || CALLSIGN=""
}


function trap_ctrl_c() {
  echo "** Trapped CTRL-C"

  if [ -e "${DB_DIRECTORY}/$CALLSIGN.log" ]
  then
    rm "${DB_DIRECTORY}/$CALLSIGN.log"
  fi

  if [ -e "$PLAIN_CALLSIGN_FILE" ]
  then
    rm "$PLAIN_CALLSIGN_FILE"
  fi

  exit 1
}


function validate_callsign() {
local CALLSIGN="$1"
  if [[ "$CALLSIGN" =~ [A-Za-z0-9]*/[A-Za-z0-9][A-Za-z0-9]* ]]
  then
    echo "Unacceptable (stroked) callsign $CALLSIGN. Exiting..."
    exit $ERROR__CALLSIGN_DOESNT_MATCH_PATTERN
  fi
}


function check_if_db_directory_exist() {
  if [ ! -d "$DB_DIRECTORY" ]
  then
    mkdir -p "$DB_DIRECTORY"
  fi
}


function obtain_info_about_callsign() {
local CALLSIGN="$1"
  if [ -e "${DB_DIRECTORY}/${CALLSIGN}.log" ]
  then
    echo "Information about callsing $CALLSIGN already obtained. Nothing to do."
  else
    echo "Getting info about $CALLSIGN..."
    
    curl \
    -s --cookie ${COOKIE_FILENAME} \
    -X POST \
    -F "tquery=$CALLSIGN" \
    -F "mode=callsign" \
    -F "id=topcall" \
    -e "https://www.qrz.com/lookup" \
    -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36' \
    "https://www.qrz.com/lookup"  | \
    html2text > "${DB_DIRECTORY}/${CALLSIGN}.log" || \
    { echo "ERROR: Cannot fetch callsign's information."; exit $ERROR__COMMUNICATION_WITH_QRZ_COM_SERVER_FAILED; };
    sleep $SLEEP_TIME
    grep -q Logout "${DB_DIRECTORY}/${CALLSIGN}.log"
    if [ $? -ne 0 ]
    then
      f_log_msg "$LOG_FILE" "Error: expired or invalid cookie file. Cannot login to http://qrz.com/"
      echo "Error: expired or invalid cookie file.
      Cannot login to http://qrz.com/"
      rm "${DB_DIRECTORY}/${CALLSIGN}.log"
      exit $ERROR__INVALID_OR_EXPIRED_COOKIE_FILE
    fi
  fi
}


function append_callsign_and_locator_to_file() {
local CALLSIGN="$1"
  SQUARE=$(html2text "${DB_DIRECTORY}/${CALLSIGN}.log" |grep "Square" | grep -o "Square [A-Za-z][A-Za-z][0-9][0-9][A-Za-z][A-Za-z]" | awk '{print $2}')
  if [[ "${SQUARE:-000000}" =~ [A-Za-z][A-Za-z][0-9][0-9][A-Za-z][A-Za-z] ]]
  then
    grep "^$CALLSIGN ${SQUARE}$" "${SCRIPT_DIR}/$CHASERS_QTH_LOCATORS_FILE" || \
    echo "$CALLSIGN $SQUARE" >> "${SCRIPT_DIR}/$CHASERS_QTH_LOCATORS_FILE"
  else
    echo "$CALLSIGN ??????"
  fi
}

function convert_to_callsign_locator_format(){
local path_to_file="$1"
local tmp=$(mktemp)

if [ $INPUT_FILE_IS_ACTIVATOR_LOG = "yes" ]
then
	cat "$path_to_file" |  grep ",FM,"  | cut -d"," -f8 | sort | uniq | grep -v "/"  > $tmp
elif [ $INPUT_FILE_IS_CHASER_LOG = "yes" ]
then
	cat "$path_to_file" | grep ",FM,"  | cut -d"," -f8 | tr  "/" " " | grep -oE "[[:alnum:]]+[[:digit:]][[:alnum:]]+" | sort | uniq > $tmp
else
	cat "$path_to_file" | sort | uniq | grep -v "/" > $tmp
fi

echo "$tmp"
}


function main_loop() {
local CALLSIGN="$1"
PLAIN_CALLSIGN_FILE=""

if [ -z $CALLSIGN ]
then

  if [ -e  "$SP_CHASERS_FILE" ]
  then
    PLAIN_CALLSIGN_FILE=$(convert_to_callsign_locator_format "$SP_CHASERS_FILE")
    while read CALLSIGN; do
	validate_callsign $CALLSIGN
	obtain_info_about_callsign $CALLSIGN
	append_callsign_and_locator_to_file $CALLSIGN
    done < "$PLAIN_CALLSIGN_FILE"
    rm "$PLAIN_CALLSIGN_FILE"
  else
    echo "File \"${SP_CHASERS_FILE}\" doesn't exist!";
    echo "Create it with one callsign per line.";
    exit 1
  fi

else
	validate_callsign $CALLSIGN
	obtain_info_about_callsign $CALLSIGN
	append_callsign_and_locator_to_file $CALLSIGN
fi
}


SCRIPT_DIR="$(dirname $(readlink -e $0))"
BASE_DIR="$(dirname \"$SCRIPT_NAME\")"
cd $(dirname $0)
. f_log_msg
. load_config_file.bash
load_config_file
open_cookie_file
parse_parameters $@
trap trap_ctrl_c INT
check_if_db_directory_exist
main_loop $CALLSIGN
exit 0
