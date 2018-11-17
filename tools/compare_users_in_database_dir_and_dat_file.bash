#!/bin/bash

function parse_parameters() {
  if [ "$#" -ne 0 ]
  then
    echo
    echo "Usage:"
    echo "$0 "
    echo
    echo "Display callsigns with issues (no locator from some reason)"
    exit 1
  fi
}


cd $(dirname $0)
parse_parameters "$@"
for user in ../SO9ARC/database/*.log
do
user=${user%.log}
user=${user##*/}
# echo QRA: $user
grep -q "$user" ../resources/chasers_locators.dat || \
echo "$user"


done
