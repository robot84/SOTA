#!/bin/bash
# First method
# cat SO9ARC-all-qsos.csv | grep -P "\w\w\d\d\w\w" | cut -d, -f8- | sed 's/,,/ /' | sed -r "s/([[:alpha:]]{2}[[:digit:]]{2}[[:alpha:]]{2})|(^\S*)/,&,/g" |  cut -d, -f2,4 | tr  "," " "

#Second - alternate method
#cat SO9ARC-all-qsos.csv  | grep -P "\w\w\d\d\w\w" | cut -d, -f8- | sed 's/,,/ /' | sed -E 's/(\w*) (.*)([[:alpha:]]{2}[[:digit:]]{2}[[:alpha:]]{2})(.*)/\1 \3/'

function parse_parameters() {
 POSITIONAL=()
  while [[ $# -gt 0 ]]
  do
    key="$1"
    
    case $key in
      -h|--help)
        echo ""
        echo "Usage:"
        echo "${0##*/} <activator_log_file.csv>"
        echo "Searching QTH Locators for callsigns in report notes of activator's log."
        echo
		echo -e "      --help\t\t\t display this help and exit"
		echo -e "      --version\t\t\t output version information and exit"
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
  
  
# activator_log="${POSITIONAL[0]}"
}


function main() {
local activator_log="$1"
cat "$activator_log" | grep -P "\w\w\d\d\w\w" | cut -d, -f8- | sed 's/,,/ /' | sed -r "s/([[:alpha:]]{2}[[:digit:]]{2}[[:alpha:]]{2})|(^\S*)/,&,/g" |  cut -d, -f2,4 | tr  "," " "
}

cd $(dirname $0)
. f_log_msg
. load_config_file.bash
load_config_file
parse_parameters $@
main $@
