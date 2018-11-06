#!/bin/bash

t001_script_runned_without_arguments_return_1() {
  ../src/get-callsign-info-page.bash > /dev/null 2> /dev/null \
  && echo Failed || echo Passed
  rm  -f ${DB_DIRECTORY}/SQ9IAW.log
}


t002_script_has_this_callsign_in_db__is_it_consious_of_that() {
  cp files/SQ9IAW.log ${DB_DIRECTORY}
  ../src/get-callsign-info-page.bash SQ9IAW | grep \
  "Nothing to do." > /dev/null && echo Passed || echo Failed
  rm -f ${DB_DIRECTORY}/SQ9IAW.log
}

t003_script_hasNOT_this_callsign_in_db__() {
  
  rm -f ${DB_DIRECTORY}/SQ9IAW.log
  ../src/get-callsign-info-page.bash SQ9IAW | grep -v "Nothing to do." > /dev/null && echo Passed || echo Failed
  rm -f ${DB_DIRECTORY}/SQ9IAW.log
}

t004_script_hasNOT_this_callsign_in_db__() {
  rm -f ${DB_DIRECTORY}/SQ9IAW.log
  ../src/get-callsign-info-page.bash SQ9IAW | grep -q \
  "Getting info about" > /dev/null && echo Passed || echo Failed
  
  rm -f ${DB_DIRECTORY}/SQ9IAW.log
}

t005_cookie_validation() {
  rm -f ${DB_DIRECTORY}/SQ9IAW.log
  TMP=$(mktemp)
  cp  "$COOKIE_FILENAME" $TMP
  cp files/good_cookie.txt  "$COOKIE_FILENAME"
  ../src/get-callsign-info-page.bash SQ9IAW  > /dev/null
  grep -q JO90xc "${DB_DIRECTORY}/SQ9IAW.log" && \
  grep -q Logout "${DB_DIRECTORY}/SQ9IAW.log" && echo Passed || echo Failed
  
  cp $TMP "$COOKIE_FILENAME"
  rm -f ${DB_DIRECTORY}/SQ9IAW.log
}


t006_cookie_validation() {
  TMP=$(mktemp)
  rm -f ${DB_DIRECTORY}/SQ9IAW.log
  cp  "$COOKIE_FILENAME" $TMP
  cp files/invalid_cookie.txt  "$COOKIE_FILENAME"
  ../src/get-callsign-info-page.bash SQ9IAW  > /dev/null
  [ ! -e ${DB_DIRECTORY}/SQ9IAW.log ] && echo Passed || echo Failed
  cp $TMP "$COOKIE_FILENAME"
  rm -f ${DB_DIRECTORY}/SQ9IAW.log
}


main() {
  cd $(dirname $0)
  . ../resources/config.cfg
  
  t001_script_runned_without_arguments_return_1
  t002_script_has_this_callsign_in_db__is_it_consious_of_that
  t003_script_hasNOT_this_callsign_in_db__
  t004_script_hasNOT_this_callsign_in_db__
  t005_cookie_validation
  t006_cookie_validation
}

main
