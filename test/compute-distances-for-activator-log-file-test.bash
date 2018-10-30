#!/bin/bash
#
#
# Version 0.0.1

PASSED_COUNT=0
FAILED_COUNT=0

cd $(dirname $0)

TEST_NAME="wc1"
cat files/activator-log.csv | ../src/compute-distances-for-activator-log-file.bash > /tmp/asdfad.tmp~
if  cmp --silent /tmp/asdfad.tmp~ files/test_result 
then
echo Test \'$TEST_NAME\' PASSED
(( PASSED_COUNT = PASSED_COUNT + 1 ))
else
echo Test \'$TEST_NAME\' FAILED
(( FAILED_COUNT = FAILED_COUNT + 1 ))
fi

echo Doing clean up...
rm /tmp/asdfad.tmp~

(( ALL_TESTS_EXECUTED = PASSED_COUNT + FAILED_COUNT ))
echo
echo Summary:
echo Tests executed:  $ALL_TESTS_EXECUTED
echo Passed: $PASSED_COUNT
echo Failed: $FAILED_COUNT

if [ $FAILED_COUNT -eq 0 ]
then
exit 0
else
exit $FAILED_COUNT
fi

