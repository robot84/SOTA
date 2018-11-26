#!/bin/bash

REPORT_SHOW=false
INPUT_FILE_IS_ACTIVATOR_LOG=no
INPUT_FILE_IS_CHASER_LOG=no
UNITS=km
header_line='Date       Time  QSO from        Callsign (QRA)  QRB'


function parse_parameters() {
 POSITIONAL=()
  while [[ $# -gt 0 ]]
  do
    key="$1"
    
    case $key in
      -h|--help)
        echo "Usage: ${0##*/} [OPTION]... <qso-log.csv>"
        echo "Compute QSOs' distances based on QSOs extracted from activator/chaser csv log."
        echo
		echo -e "  -a, --activator-log\t\t input file is .csv activator log downloaded from sotadata.org.uk"
		echo -e "  -c, --chaser-log\t\t input file is .csv chaser log downloaded from sotadata.org.uk"
    	echo -e "  -r, --show-report\t\tShow RS SENT/RCVD report for each QSO."
        echo -e "  -m, --miles\tprint in miles insted of km"
        echo -e "  -v, --verbose\tprint some application diagnose messages"
		echo
		echo -e "      --help\t\t\t display this help and exit"
		echo -e "      --version\t\t\t output version information and exit"
		echo
    	echo -e "\t\tTo download activator/chaser log:"
		echo -e "\t\t*login to https://sotadata.org.uk/"
		echo -e "\t\t*navigate via menu:"
		echo -e "\t\ta) for activator:"
    	echo -e "\t\tView Results->My results->My Activator Log"
    	echo -e "\t\tAt the bottom of this page click 'Download complete log'"
		echo -e "\t\tb) for chaser:"
    	echo -e "\t\tView Results->My results->My Chaser Log"
    	echo -e "\t\tAt the top of the page click 'Download complete log'"
        exit 1
      ;;
       -a|--activator-log)
		INPUT_FILE_IS_ACTIVATOR_LOG=yes
        shift
      ;;
       -c|--chaser-log)
		INPUT_FILE_IS_CHASER_LOG=yes
        shift
		;;
	   -r|--show-report)
		REPORT_SHOW=true
		shift
		;;
	   -v|--verbose)
	   VERBOSE_ENABLED=yes
	   shift
	   ;;
	   -m|--miles)
	   UNITS=miles
	   print_debug_msg "US miles as units enabled."
	   shift
	   ;;
       --version)
		print_version_info
        exit
      ;;
      -*)
        echo "$0: invalid option -- '$key'"
        echo "Try '$0 --help' for more information."
        exit
      ;;
      *)
        POSITIONAL+=("$1") # save it in an array for later
        shift
      ;;
    esac
  done

    if [ "${#POSITIONAL[@]}" -lt 1 ]
  then
    echo "$0: Mandatory argument ommited."
    echo "Try '${0##*/} --help' for more information."
    exit 1
  fi
  
  qso_log_file="${POSITIONAL[0]}"
}


function trap_ctrl_c() {
	echo "** Trapped CTRL-C"
	if [ -f $TMP_FILE ]
	then
		rm "$TMP_FILE"
	fi

	exit 1
}


function create_tmp_file() {
  TMP_FILE=$(mktemp)
  touch $TMP_FILE
#  exit_if_file_not_exist $TMP_FILE
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
}

function open_summits_qth_locations_file() {
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
}

function open_chasers_qth_locations_file() {
  if [ ! -f "$CHASERS_QTH_LOCATORS_FILE" ]
  then
    echo "$0: Error: Can not open file $CHASERS_QTH_LOCATORS_FILE Check if file exists"
    exit 3
  fi
  
  if [ ! -r "$CHASERS_QTH_LOCATORS_FILE" ]
  then
    echo "$0: Error: Can not open file $CHASERS_QTH_LOCATORS_FILE for reading"
    exit 3
  fi
}

function put_miles_switch_if_neccesary() {
if [ "$UNITS" = miles ]
then
echo -m
fi
}

function get_distances_based_on_activator_log() {
  cat "$qso_log_file" | awk -F, ' {print $3,$4,$5,$6,$8,$10}' > $TMP_FILE
  printf "$header_line [$UNITS]\n"
  while read SUMMIT QSO_DATE QSO_TIME QSO_BAND CALLSIGN REPORT_AND_NOTES;
  do
    SUMMIT_QTH_LOCATOR=$(cat "${SUMMITS_QTH_LOCATORS_FILE}" | grep "$SUMMIT " | awk '{print $2}')
    CHASERS_QTH_LOCATOR=$(cat "${CHASERS_QTH_LOCATORS_FILE}" | grep "$CALLSIGN " | awk '{print $2}')
    
    if [ -z "$CHASERS_QTH_LOCATOR" -o -z "$SUMMIT_QTH_LOCATOR" ]
    then
      f_log_msg "$ERROR_LOG_FILE" "Warning: summit locator ($SUMMIT_QTH_LOCATOR) \
	  or callsign locator ($CHASERS_QTH_LOCATOR) is empty or not set."
    else
      DISTANCE=$(
	  	"$SCRIPT_DIR/get-distanse-beetween-locators.bash" \
		-s \
	  	"$GET_DISTANCE_OPTIONS" \
		"${VERBOSE_ENABLED/yes/-v}" \
		$SUMMIT_QTH_LOCATOR $CHASERS_QTH_LOCATOR \
		$(put_miles_switch_if_neccesary) \
		)
      echo -en "$QSO_DATE $QSO_TIME $SUMMIT\t $CALLSIGN\t\t $DISTANCE"
      [ "$REPORT_SHOW" = "true" ] && echo -e "\t\t$REPORT_AND_NOTES" || echo ""
    fi
  done <$TMP_FILE
  rm $TMP_FILE
}

function get_distances_based_on_chaser_log() {
  cat "$qso_log_file" | awk -F,  ' {print $9,$4,$5,$2,$10}' > $TMP_FILE
  printf "$header_line [$UNITS]\n"
  while read SUMMIT QSO_DATE QSO_TIME CALLSIGN REPORT_AND_NOTES;
  do
    SUMMIT_QTH_LOCATOR=$(cat "${SUMMITS_QTH_LOCATORS_FILE}" | grep "$SUMMIT " | awk '{print $2}')
    CHASERS_QTH_LOCATOR=$(cat "${CHASERS_QTH_LOCATORS_FILE}" | grep "$CALLSIGN " | awk '{print $2}')
    if [ -z "$CHASERS_QTH_LOCATOR" -o -z "$SUMMIT_QTH_LOCATOR" ]
    then
      f_log_msg "$ERROR_LOG_FILE" "Warning: summit locator ($SUMMIT_QTH_LOCATOR) \
	  or callsign locator ($CHASERS_QTH_LOCATOR) is empty or not set."
    else
      DISTANCE=$(
	  	"$SCRIPT_DIR/get-distanse-beetween-locators.bash" \
		-s \
		"${VERBOSE_ENABLED/yes/-v}" \
	  	"$GET_DISTANCE_OPTIONS" \
		$SUMMIT_QTH_LOCATOR $CHASERS_QTH_LOCATOR \
		$(put_miles_switch_if_neccesary) \
		)
      echo -en "$QSO_DATE $QSO_TIME $SUMMIT\t $CALLSIGN\t\t $DISTANCE"
      [ "$REPORT_SHOW" = "true" ] && echo -e "\t\t$REPORT_AND_NOTES" || echo ""
    fi
  done <$TMP_FILE
  rm $TMP_FILE
}

function get_distances() {
if [ $INPUT_FILE_IS_ACTIVATOR_LOG = "yes" ]
then
get_distances_based_on_activator_log "$1"
elif [ $INPUT_FILE_IS_CHASER_LOG = "yes" ]
then
get_distances_based_on_chaser_log "$1"
else
echo "You must specify one of these options: -a or -c"
echo "Exiting..."
exit 1
fi
}

SCRIPT_DIR="$(dirname $(readlink -e $0))"
BASE_DIR="$(dirname \"$SCRIPT_NAME\")"
. "$SCRIPT_DIR/common_functions"
load_config_file "$SCRIPT_DIR"
qso_log_file=""
parse_parameters $@
trap trap_ctrl_c INT
create_tmp_file
open_summits_qth_locations_file
open_chasers_qth_locations_file
get_distances
