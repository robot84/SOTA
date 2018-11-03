#!/bin/bash
#

SP_CHASERS_FILE=""

cd $(dirname $0)
. load_config_file.bash

if [ "$#" -lt 1 ]
then
echo "${0##*/}: Mandatory argument ommited."
echo "Try '${0##*/} --help' for more information."
exit 1
fi



POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
     -h|--help)
		echo "Usage:"
		echo "$0 <-f filename> "
		echo "Searching QTH Locators for callsigns from file."
		echo
		echo -e " -f,--filename\tfile with callsign list, one callsign per line"
		echo
		exit 1
	;;
	-f|--callsigns-list)
	SP_CHASERS_FILE="$2"
	shift
	shift
	;;
	--version)
		echo "Copyright (C) 2018 SO9ARC"
		echo "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/license
		s/gpl.html>."
		echo "This is free software: you are free to change and redistribute it.
		"
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
	shift # past argument
	;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters



trap ctrl_c INT

function ctrl_c() {
echo "** Trapped CTRL-C"
if [ -e "${DB_DIRECTORY}/$CALLSIGN.log" ]
then
rm "${DB_DIRECTORY}/$CALLSIGN.log"
fi
exit
}


if [ -e  "$SP_CHASERS_FILE" ]
then
	while read CALLSIGN; do
	bash ./get-callsign-info-page.bash $CALLSIGN
	  done < "$SP_CHASERS_FILE"
else
	echo "File \"${SP_CHASERS_FILE}\" doesn't exist!";
	echo "Create it with one callsign per line.";
	exit 1
fi
