#!/bin/bash

function parse_parameters() {
  POSITIONAL=()
  while [[ $# -gt 0 ]]
  do
    key="$1"
    
    case $key in
      -h|--help)
        echo "Usage:"
        echo "cat qso-log.csv | ${0##*/}"
        echo "Analyze your QSO log file against future issues, you can
        experience, when you run compute-distances-for-activator-log.bash on it"
        echo
        echo -e "qso-log.csv\tdownload it from http://sotadata.org.uk/"
        echo -e "\t\tTo do this, navigate via menu:"
        echo -e "\t\tView Results->My results->My Activator Log"
        echo -e "\t\tAt the bottom of this page click 'Download complete log'"
        echo
        
        exit $ERROR__NO_CALLSIGN_PASSED_TO_SCRIPT
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
}




function parse_qsos() {
  TMP_FILE=$(mktemp)
  cat - | awk -F, ' {print $3,$4,$5,$6,$8,$10}' > $TMP_FILE
  
  while read SUMMIT D4 D5 D6 CALLSIGN D10;
  do
    SUMMIT_QTH=`cat "$SUMMITS_QTH_LOCATORS_FILE" | grep "$SUMMIT" | awk '{print $2}'`
    CALLSIGN_QTH=`cat "$CHASERS_QTH_LOCATORS_FILE" | grep "$CALLSIGN" | awk '{print $2}'`
    
    
    if [[ -z $CALLSIGN_QTH ]]
    then
      echo "No callsign $CALLSIGN in database."
      # echo "Meybe you want to run create-pair-callsign-locator-from-full-qrz-com-info-page.bash script"
      #echo  "Error when processing QSO from $SUMMIT ($SUMMIT_QTH) with $CALLSIGN ($CALLSIGN_QTH) $D4 $D5 $D6 Notes: $D10"
    fi
    
    if [[ $CALLSIGN_QTH = "??????" ]];
    then
      echo "Callsign $CALLSIGN has no QTH Locator in database"
    fi
    
  done <$TMP_FILE
  rm $TMP_FILE
}


cd $(dirname $0)
. load_config_file.bash
load_config_file
parse_parameters $@
parse_qsos

