#!/bin/bash
#3 testy!
#jeden jak zwraca ze nothing to do, a drugi jak sciaga info z serwera
#wtedy mamy 100% pokrycia kodu i rozgalezien
#a trzeci zeby usage pokazalo
#w TDD bym to zrobil tak:

t001_script_runned_without_arguments_return_1() {

../src/get-callsign-info-page.bash > /dev/null 2> /dev/null \
&& echo Failed || echo Passed
}


t002_script_has_this_callsign_in_db__is_it_consious_of_that() {
cp files/SQ9IAW.log ${DB_DIRECTORY}
../src/get-callsign-info-page.bash SQ9IAW | grep \
"Nothing to do." > /dev/null && echo Passed || echo Failed
}

t003_script_hasNOT_this_callsign_in_db__() {

rm -f ${DB_DIRECTORY}/SQ9IAW.log
../src/get-callsign-info-page.bash SQ9IAW | grep -v "Nothing to do." > /dev/null && echo Passed || echo Failed

}

t004_script_hasNOT_this_callsign_in_db__() {
rm  ${DB_DIRECTORY}/SQ9IAW.log
../src/get-callsign-info-page.bash SQ9IAW | grep \
"Getting info about" > /dev/null && echo Passed || echo Failed



}

main() {
cd $(dirname $0)
. ../resources/config.cfg

t001_script_runned_without_arguments_return_1
t002_script_has_this_callsign_in_db__is_it_consious_of_that
t003_script_hasNOT_this_callsign_in_db__
t004_script_hasNOT_this_callsign_in_db__
}

main 
