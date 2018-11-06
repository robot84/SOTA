#!/bin/bash
#
#
# Example of output:
# 3Z9AM JO90xa
# HF9D JO90ki
# OK2BTC JN99jo
#


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
        echo -e "SP9ABC ??????\t it means that user not provided to qrz.com his QTH Locator."
        echo "\t\t\tin this case you must obtain it from other sources."
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
  cd "${DB_DIRECTORY}"
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
      echo "$CALLSIGN $SQUARE" >> "${SCRIPT_DIR}/$CHASERS_QTH_LOCATORS_FILE"
    fi
  done
  
  TMP_FILE=$(mktemp)
  cp "${SCRIPT_DIR}/$CHASERS_QTH_LOCATORS_FILE" "$TMP_FILE"
  f_log_msg "${SCRIPT_DIR}/$LOG_FILE" "Notice: Recreating database. Backed up chasers_locators.dat file as $TMP_FILE"
  cat "$TMP_FILE" | grep -vE "\?{6}"| sort | uniq > "${SCRIPT_DIR}/$CHASERS_QTH_LOCATORS_FILE"
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
