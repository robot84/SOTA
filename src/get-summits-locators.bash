#!/bin/bash
# This script extract summits' QTH locators from region info pasted from sotadata.org.uk/summits.aspx
#
# Robert Zabkiewicz (c) 2018
# Version 0.0.3
#
# Revision history:
# 0.0.1		initial version
# 0.0.2		fixed bug, if user paste table with header, now it is ok

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

sed 's/ /_/g' ${1} | awk '{print $1, $7}' | grep -P '\w+/\w+-\d+ \w\w\d\d\w\w'
