#!/bin/bash
CONFIG_FILE="../resources/config.cfg"
ERROR__CANNOT_LOAD_CONFIG_FILE=100


function if_config_file_exists() {
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


function load_config_file() {
.  ${CONFIG_FILE}
}


function set_working_dir() {
SCRIPT_DIR=$(dirname $0)
ACTUAL_DIR=$(pwd)
ORIGINAL_DIR=""
if [ "$SCRIPT_DIR" != "$ACTUAL_DIR" ]
then
cd "$SCRIPT_DIR"
ORIGINAL_DIR=$ACTUAL_DIR
fi
}


function restore_original_dir() {
if [ -n "$ORIGINAL_DIR" ]
then
cd "$ACTUAL_DIR" > /dev/null
fi
}


function main() {

set_working_dir
if_config_file_exists
load_config_file
restore_original_dir
}

main $@

