#!/bin/bash
function parse_parameters() {
 POSITIONAL=()
  while [[ $# -gt 0 ]]
  do
    key="$1"
    
    case $key in
      -h|--help)
        echo ""
        echo "Usage:"
        echo "${0##*/} <file_with_callsigns_of_users_than_didnt_provide_locator_info>"
        echo "Obtain detailed info from qrz.com for users,
		than haven't got locator information on this site."
        echo
		echo -e "      --help\t\t\t display this help and exit"
		echo -e "      --version\t\t\t output version information and exit"
		echo
		echo "First these particular users must be quered by get-callsign-info-page script.
		There must be a "footprint" of users in script's database.
		So run this script for users that get-callsign-info-page returned an error:
		'User didn't provided his QTH Locator on http://qrz.com'

		Input file format is - one callsign per line. For example:
		SQ9MUR
		SQ9NOO
		SQ9OJS
		SQ9OJT
		SQ9ROU

		"
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

   if [ "$#" -lt 1 ]
  then
    echo "$0: Mandatory argument ommited."
    echo "Try '$0 --help' for more information."
    f_log_msg "$ERROR_LOG_FILE" "No activator log passed to script."
    exit 1
  fi
}


function main(){
for name in $(cat $1)
do
echo QRA: $name
echo ---------------------------------------------
cat "$DB_DIRECTORY/${name}.log" | grep  -C 3 "_L-HROutlet"
echo ---------------------------------------------
done
}


cd $(dirname $0)
. f_log_msg
. load_config_file.bash
load_config_file
parse_arguments $@
main $@
