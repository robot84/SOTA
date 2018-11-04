#!/bin/bash
#
#
pwd
. ../src/load_config_file.bash

PASSED_COUNT=0
FAILED_COUNT=0

function t001_test() {
TEST_NAME="wc1"
cp "$SUMMITS_QTH_LOCATORS_FILE" ../test/files/summits_locators.backup
rm "$SUMMITS_QTH_LOCATORS_FILE"
../src/get-summits-locators.bash ../test/files/region.tmp
RESULT=`cat "$SUMMITS_QTH_LOCATORS_FILE" | wc -l`
if [ $RESULT -eq 74 ]
then
echo Test \'$TEST_NAME\' PASSED
(( PASSED_COUNT = PASSED_COUNT + 1 ))
else
echo Test \'$TEST_NAME\' FAILED
(( FAILED_COUNT = FAILED_COUNT + 1 ))
fi
cp ../test/files/summits_locators.backup "$SUMMITS_QTH_LOCATORS_FILE" 
}

function t002_test() {
TEST_NAME="wc2"
cp "$SUMMITS_QTH_LOCATORS_FILE" ../test/files/summits_locators.backup
rm "$SUMMITS_QTH_LOCATORS_FILE"
../src/get-summits-locators.bash ../test/files/region.tmp
RESULT=`cat "$SUMMITS_QTH_LOCATORS_FILE"  | grep -cP '\w+/\w+-\d+ \w\w\d\d\w\w'`
if [ $RESULT -eq 74 ]
then
echo Test \'$TEST_NAME\' PASSED
(( PASSED_COUNT = PASSED_COUNT + 1 ))
else
echo Test \'$TEST_NAME\' FAILED
(( FAILED_COUNT = FAILED_COUNT + 1 ))
fi
cp ../test/files/summits_locators.backup "$SUMMITS_QTH_LOCATORS_FILE" 
}

function t003_test() {
TEST_NAME="wc3"
cp "$SUMMITS_QTH_LOCATORS_FILE" ../test/files/summits_locators.backup
rm "$SUMMITS_QTH_LOCATORS_FILE"
../src/get-summits-locators.bash ../test/files/region.tmp
RESULT=`cat "$SUMMITS_QTH_LOCATORS_FILE"  | grep -cPv '\w+/\w+-\d+ \w\w\d\d\w\w'`
if [ $RESULT -eq 0 ]
then
echo Test \'$TEST_NAME\' PASSED
(( PASSED_COUNT = PASSED_COUNT + 1 ))
else
echo Test \'$TEST_NAME\' FAILED
(( FAILED_COUNT = FAILED_COUNT + 1 ))
fi
cp ../test/files/summits_locators.backup "$SUMMITS_QTH_LOCATORS_FILE" 
}

function print_summary() {
(( ALL_TESTS_EXECUTED = PASSED_COUNT + FAILED_COUNT ))
echo
echo Summary:
echo Tests executed:  $ALL_TESTS_EXECUTED
echo Passed: $PASSED_COUNT
echo Failed: $FAILED_COUNT
}

function end() {
if [ $FAILED_COUNT -eq 0 ]
then
exit 0
else
exit $FAILED_COUNT
fi
}


function main() {
t001_test
t002_test
t003_test
print_summary
end
}


main 
