#!/bin/bash

function check_result() {
#return 0 if return code of last command is equal $1
[ $? -eq $1 ] && { echo Passed ${FUNCNAME[1]}; return 0; } || { echo Failed ${FUNCNAME[1]};return 1; };
}

t001_() {
type is_valid_locator > /dev/null
check_result 0
}

t002_() {
(is_valid_locator JO90ab > /dev/null)
check_result 0
}

t003_() {
(is_valid_locator JO90 > /dev/null)
check_result 1
}

t004_() {
(is_valid_locator JO90abb > /dev/null)
check_result 1
}

t005_() {
(is_valid_locator JJO90ab > /dev/null)
check_result 1
}

t006_() {
(is_valid_locator -JO90abb > /dev/null)
check_result 1
}

t007_() {
(is_valid_locator JOJOab > /dev/null)
check_result 1
}

t008_() {
(is_valid_locator JOJO90 > /dev/null)
check_result 1
}

t009_() {
(is_valid_locator  > /dev/null)
check_result 1
}

t010_() {
(test is_valid_callsign > /dev/null)
check_result 0
}

t011_() {
(is_valid_callsign SO9arc > /dev/null)
check_result 0
}

t012_() {
(is_valid_callsign SO9ARC/9 > /dev/null)
check_result 0
}

t013_() {
(is_valid_callsign SO9ARC/P > /dev/null)
check_result 0
}

t014_() {
(is_valid_callsign OK/SO9ARC/P > /dev/null)
check_result 0
}

t015_() {
(is_valid_callsign > /dev/null)
check_result 1
}

t016_() {
(is_valid_callsign SQ9X > /dev/null)
check_result 0
}

t017_() {
(is_valid_callsign SQ9X/P > /dev/null)
check_result 0
}

t018_() {
(is_valid_callsign SQ9PG/P > /dev/null)
check_result 0
}

t019_() {
(is_valid_callsign 3Z0NWA > /dev/null)
check_result 0
}

t020_() {
(is_valid_callsign 2E0KVGN > /dev/null)
check_result 0
}

t021_() {
(is_valid_callsign CS7AFM > /dev/null)
check_result 0
}

t022_() {
(is_valid_callsign DD5DXD > /dev/null)
check_result 0
}

t023_() {
(is_valid_callsign D > /dev/null)
check_result 1
}

t024_() {
(is_valid_callsign 9 > /dev/null)
check_result 1
}

t025_() {
(is_valid_callsign W9 > /dev/null)
check_result 1
}

t026_() {
(is_valid_callsign 9U > /dev/null)
check_result 1
}



main() {
.  $(dirname $0)/../src/common_functions
  
  local overall_status=passed
  for i in {01..26}
  do
  t0${i}_ || overall_status=failed
  done

echo Overall status is $overall_status
}


main
