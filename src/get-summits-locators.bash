#!/bin/bash
# This script extract summits' QTH locators from region info pasted from sotadata.org.uk/summits.aspx
#
#
#

function parse_parameters(){
 POSITIONAL=()
  while [[ $# -gt 0 ]]
  do
    key="$1"
    
    case $key in
      -h|--help)
		echo "Usage: ${0##*/} <region-info-file-name>"
		echo "Building summits locators database for data copied from sotada.org.uk"
		echo
		echo "Please pass as the argument name of a file containing information about region"
		echo "obtained from http://sotadata.org.uk/summits.aspx by"
		echo "setting desired Assosiation and Region"
		echo "then clicking Submit"
		echo "and at least copying displayed table (only the table with data, not all text on site!)"
		echo "and pasting to this file"
		echo
		echo -e " --version\t print version info and exit"
		echo -e " --help\t print this help and exit"
		exit 1
      ;;
	  --version)
		print_version_info
		  exit
		  ;;
      -*)
        echo "${0##*/}: invalid option -- '$1'"
        echo "Try '$0 --help' for more information."
        exit 1
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
    echo "${0##*/}: too less parameters."
    echo "Run ${0##*/} --help for more info."
    exit 1
  fi
  
  input_file="${POSITIONAL[0]}"
}


function open_summits_qth_locators_file_for_writing() {
  if [ -f "$SUMMITS_QTH_LOCATORS_FILE" ] && [ ! -w "$SUMMITS_QTH_LOCATORS_FILE" ]
  then
    echo "$0: Error: Can not write to file $SUMMITS_QTH_LOCATORS_FILE"
    exit 1
  fi
}


function write_locators() {
local input_file="$1"
  sed 's/ /_/g' "$input_file" | awk '{print $1, $7}' | grep -P '\w+/\w+-\d+ \w\w\d\d\w\w' >> "$SUMMITS_QTH_LOCATORS_FILE"
}


SCRIPT_DIR="$(dirname $(readlink -e $0))"
. "$SCRIPT_DIR/common_functions"
load_config_file "$SCRIPT_DIR"
input_file=""
parse_parameters $@
open_summits_qth_locators_file_for_writing
write_locators "$input_file"


