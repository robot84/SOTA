#!/bin/bash
#
# (c) SO9ARC Robert Zabkiewicz 2018
#
#$SLEEP_TIME - getting better performance against 500 Too Many Requests server's response. In seconds.
#

SLEEP_TIME=2
ERROR__NO_CALLSIGN_PASSED_TO_SCRIPT=1
ERROR__CALLSIGN_DOESNT_MATCH_PATTERN=2
ERROR__COMMUNICATION_WITH_QRZ_COM_SERVER_FAILED=3
ERROR__CANNOT_OPEN_COOKIE_FILE_FOR_READING=5
ERROR__INVALID_OR_EXPIRED_COOKIE_FILE=6


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
	echo "${0##*/} <callsign>"
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

CALLSIGN="$1"
}

function validate_callsign() {
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
SQUARE=$(html2text "${DB_DIRECTORY}/${CALLSIGN}.log" |grep "Square" | grep -o "Square [A-Za-z][A-Za-z][0-9][0-9][A-Za-z][A-Za-z]" | awk '{print $2}')
if [[ "${SQUARE:-000000}" =~ [A-Za-z][A-Za-z][0-9][0-9][A-Za-z][A-Za-z] ]]
then
grep "^$CALLSIGN ${SQUARE}$" "${SCRIPT_DIR}/$CHASERS_QTH_LOCATORS_FILE" || \
echo "$CALLSIGN $SQUARE" >> "${SCRIPT_DIR}/$CHASERS_QTH_LOCATORS_FILE"
else
echo "$CALLSIGN ??????"
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
validate_callsign
check_if_db_directory_exist
obtain_info_about_callsign
append_callsign_and_locator_to_file
exit 0
