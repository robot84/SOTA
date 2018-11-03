#!/bin/bash
CONFIG_FILE="../resources/config.cfg"
ERROR__CANNOT_LOAD_CONFIG_FILE=100

cd $(dirname $0)
if [ -r ${CONFIG_FILE} ]
then
.  ${CONFIG_FILE}
else
echo "ERROR: Cannot open config file for reading!"
echo "Check if file exists and you have permissions to read it."
echo "Path to file: ${CONFIG_FILE}"
echo "Cannot continue. Exiting..."
exit $ERROR__CANNOT_LOAD_CONFIG_FILE
fi

cd - > /dev/null
