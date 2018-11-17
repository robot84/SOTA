#!/bin/bash
# First method
# cat SO9ARC-all-qsos.csv | grep -P "\w\w\d\d\w\w" | cut -d, -f8- | sed 's/,,/ /' | sed -r "s/([[:alpha:]]{2}[[:digit:]]{2}[[:alpha:]]{2})|(^\S*)/,&,/g" |  cut -d, -f2,4 | tr  "," " "

#Second - alternate method
#cat SO9ARC-all-qsos.csv  | grep -P "\w\w\d\d\w\w" | cut -d, -f8- | sed 's/,,/ /' | sed -E 's/(\w*) (.*)([[:alpha:]]{2}[[:digit:]]{2}[[:alpha:]]{2})(.*)/\1 \3/'

cat $1 | grep -P "\w\w\d\d\w\w" | cut -d, -f8- | sed 's/,,/ /' | sed -r "s/([[:alpha:]]{2}[[:digit:]]{2}[[:alpha:]]{2})|(^\S*)/,&,/g" |  cut -d, -f2,4 | tr  "," " "
