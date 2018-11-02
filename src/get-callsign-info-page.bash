#!/bin/bash
#
# (c) SO9ARC Robert Zabkiewicz 2018
#
# VER=0.1.2
#$SLEEP_TIME - getting better performance against 500 Too Many Requests server's response. In seconds.
#
# Revision History:
# 0.1.2 we don't accept stroked callsigns like W7ABC/x, etc
# 0.1.3 different exit codes for different errors
# 0.1.4 use config.cfg for loading information about database localization

CONFIG_FILE="../resources/config.cfg"
SLEEP_TIME=2
ERROR__NO_CALLSIGN_PASSED_TO_SCRIPT=1
ERROR__CALLSIGN_DOESNT_MATCH_PATTERN=2
ERROR__COMMUNICATION_WITH_QRZ_COM_SERVER_FAILED=3
ERROR__CANNOT_LOAD_CONFIG_FILE=4
ERROR__NO_COOKIE=5

### Functions ###

# f_log_msg() - Logging a message to log file
#
# Arguments: log_filename message_to_log
# Return: nothing
#
# Example; f_log_msg ../log/error.log "Error: Failure foo."
#
f_log_msg() {
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

### End of Functions ###

### Main ###
cd $(dirname $0)
if [ -r ${CONFIG_FILE} ]
then
.  ${CONFIG_FILE}
else
echo "Cannot open config file for reading!"
echo "Check if file exists and you have permissions to read it."
echo "Path to file: ${CONFIG_FILE}"
echo "Cannot continue. Exiting..."
exit $ERROR__CANNOT_LOAD_CONFIG_FILE
fi

if [ ! -r ${COOKIE_FILENAME} ]
then
echo $COOKIE_FILENAME
echo Nie ma ciasteczek!
#mkdir -p $(dirname ${COOKIE_FILENAME})
# touch ${COOKIE_FILENAME}

	f_log_msg $LOG_FILE "Error: no cookie file available. Cannot login to http://qrz.com/"
	exit $ERROR__NO_COOKIE
fi

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

if [[ "$CALLSIGN" =~ [A-Za-z0-9]*/[A-Za-z0-9][A-Za-z0-9]* ]]
then
echo "Unacceptable (stroked) callsign $CALLSIGN. Exiting..."
exit $ERROR__CALLSIGN_DOESNT_MATCH_PATTERN
fi
 

if [ ! -d "$DB_DIRECTORY" ]
then
	mkdir "$DB_DIRECTORY"
fi

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
"https://www.qrz.com/lookup"  |\
html2text > "${DB_DIRECTORY}/$CALLSIGN.log" || \
{ echo "ERROR: Cannot fetch callsign's information."; exit $ERROR__COMMUNICATION_WITH_QRZ_COM_SERVER_FAILED; };

sleep $SLEEP_TIME
fi

cd - >> /dev/null
exit 0
