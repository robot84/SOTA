#!/bin/bash
ERROR__CANNOT_LOAD_CONFIG_FILE=100

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


