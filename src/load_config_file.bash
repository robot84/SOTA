#!/bin/bash
ERROR__CANNOT_LOAD_CONFIG_FILE=100

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

function print_version_info(){

	echo "${0##*/} $APP_VER"
		echo "Copyright (C) 2018 SO9ARC"
		echo "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>."
		echo "This is free software: you are free to change and redistribute it. "
		echo "There is NO WARRANTY, to the extent permitted by law."
		echo
		echo "Written by Robert Zabkiewicz SO9ARC."
#       echo "Report bugs to bug@somemail.org"
#       echo "GNU coreutils home page: <http://kamery-tatry.ovh.net/coreutils/>"
}


function if_file_exists() {
  if [ ! -r "$1" ]
  then
    echo "ERROR: Cannot open ${2:- } file for reading!"
    echo "Check if file exists and you have permissions to read it."
    echo "You tried to find: $(readlink -m $1)"
	local proposition=
 	[ -d " $(dirname $(readlink -m $1))" ] && \
	proposition=$(find $(dirname $(readlink -m $1)) -name $(basename $1) -print)
	[ ! -z $proposition ] && echo "Maybe you are looking for $proposition ?"
	proposition=
	[ -d "../$(dirname $1)" ] && \
 	proposition=$(find  ../$(dirname $1) -name $(basename $1) -print)
	[ ! -z $proposition ] && echo "Maybe you are looking for $proposition ?"
    echo "Cannot continue. Exiting..."
    exit $ERROR__CANNOT_LOAD_CONFIG_FILE
  else
    return 0
  fi
}


function if_config_file_exists() {
CONFIG_FILE="$1/../resources/config.cfg"
  if [ ! -r ${CONFIG_FILE} ]
  then
    echo "ERROR: Cannot open config file for reading!"
    echo "Check if file exists and you have permissions to read it."
    echo "Path to file: ${CONFIG_FILE}"
    echo "Cannot continue. Exiting..."
    exit $ERROR__CANNOT_LOAD_CONFIG_FILE
  else
    return 0
  fi
}


# temporary obsolete
function set_working_dir() {
  
  ACTUAL_DIR=$(pwd)
  ORIGINAL_DIR=""
  if [ "$SCRIPT_DIR" != "$ACTUAL_DIR" ]
  then
    cd "$SCRIPT_DIR"
    ORIGINAL_DIR=$ACTUAL_DIR
  fi
}


# temporary obsolete
function restore_original_dir() {
  if [ -n "$ORIGINAL_DIR" ]
  then
    cd "$ACTUAL_DIR" > /dev/null
  fi
}

function load_config_file() {
  if_config_file_exists "$1"
  .  ${CONFIG_FILE}
}


