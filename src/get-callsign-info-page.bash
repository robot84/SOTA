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


# f_log_msg() - Logging a message to log file
#
# Arguments: log_filename message_to_log
# Return: nothing
#
# Example; f_log_msg ../log/error.log "Error: Failure foo."
#
function f_log_msg() {
LOG_FILE_NAME="${1}"
shift
[ ! -e ${LOG_FILE_NAME} ] && \
 ( mkdir -p $(dirname ${LOG_FILE_NAME}); touch ${LOG_FILE_NAME}; )

LOG_DATE=`LC_ALL=C date "+%b %e %H:%M:%S"`
LOG_HOST=`hostname -s`
LOG_PROCESS=$(basename $0)
LOG_PID=$BASHPID
LOG_MSG="$@"
echo "$LOG_DATE $LOG_HOST $LOG_PROCESS[$LOG_PID]: $LOG_MSG" >> "${LOG_FILE_NAME}"
}

cd $(dirname $0)
function load_config_file() {
. load_config_file.bash
}

function open_cookie_file() {
if [ ! -r ${COOKIE_FILENAME} ]
then
echo $COOKIE_FILENAME
echo "Error: Cannot open cookie file for read."
echo "Check if cookie file ${COOKIE_FILENAME} exists 
and you have permissions for reading it."

	f_log_msg $LOG_FILE "Error: no cookie file available. Cannot login to http://qrz.com/"
exit $ERROR__CANNOT_OPEN_COOKIE_FILE_FOR_READING
fi
}

function parse_parameters() {
if [ "$#" -lt 1 ]
then
echo "$0: Mandatory argument ommited."
echo "Try '$0 --help' for more information."
	 f_log_msg $LOG_FILE ${!ERROR__NO_CALLSIGN_PASSED_TO_SCRIPT@}
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
	mkdir "$DB_DIRECTORY"
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

grep -q Logout "${DB_DIRECTORY}/${CALLSIGN}.log"
if [ $? -ne 0 ]
then
	f_log_msg $LOG_FILE "Error: expired or invalid cookie file. Cannot login to http://qrz.com/"
	echo "Error: expired or invalid cookie file. 
	Cannot login to http://qrz.com/"
	rm "${DB_DIRECTORY}/${CALLSIGN}.log"
	exit $ERROR__INVALID_OR_EXPIRED_COOKIE_FILE
fi

sleep $SLEEP_TIME

fi
cd - >> /dev/null
exit 0
}

load_config_file
open_cookie_file
parse_parameters $@
validate_callsign
check_if_db_directory_exist
obtain_info_about_callsign
