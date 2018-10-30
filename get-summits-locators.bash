#!/bin/bash
# This script extract summits' QTH locators
#
# Robert Zabkiewicz (c) 2018
# Version 0.0.3
#
# Usage:
# 1. go to below web site in your web browser
#	http://sotadata.org.uk/summits.aspx
# 2. Set desired Assosiation and Region
# 3. Click Submit
# 4. copy and paste table of summits from this site to text file and name it locators.txt
# 5. use commands wrote out below on this file

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

sed 's/ /_/g' ${1} | awk '{print $1, $7}'
