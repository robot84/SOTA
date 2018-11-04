#!/bin/bash
# This script extract summits' QTH locators from region info pasted from sotadata.org.uk/summits.aspx
#
#
#

function parse_parameters() {
if [ "$#" -ne 1 ]
then
echo
echo "Usage:"
echo "$0 <region-info-file-name>"
echo
echo "Please pass as the argument name of a file containing information about region"
echo "obtained from http://sotadata.org.uk/summits.aspx by"
echo "setting desired Assosiation and Region"
echo "then clicking Submit"
echo "and at least copying displayed table (only the table with data, not all text on site!)"
echo "and pasting to this file"
echo
exit 1
fi
}

function open_summits_qth_locators_file_for_writing() {
if [ -f "$(dirname $0)/$SUMMITS_QTH_LOCATORS_FILE" ] && [ ! -w "$(dirname $0)/$SUMMITS_QTH_LOCATORS_FILE" ]
then
echo "$0: Error: Can not write to file $SUMMITS_QTH_LOCATORS_FILE"
exit 1
fi
}


function write_locators() {
sed 's/ /_/g' ${1} | awk '{print $1, $7}' | grep -P '\w+/\w+-\d+ \w\w\d\d\w\w' >> "$(dirname $0)/$SUMMITS_QTH_LOCATORS_FILE"
}


cd $(dirname $0)
. load_config_file.bash
load_config_file
parse_parameters $@
open_summits_qth_locators_file_for_writing
write_locators $@


