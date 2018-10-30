#!/bin/bash
#
#
# Version 0.0.1

PASSED_COUNT=0
FAILED_COUNT=0

TEST_NAME="wc1"
RESULT=`../get-summits-locators.bash files/region.tmp | wc -l`
if [ $RESULT -eq 74 ]
then
echo Test \'$TEST_NAME\' PASSED
(( PASSED_COUNT = PASSED_COUNT + 1 ))
else
echo Test \'$TEST_NAME\' FAILED
(( FAILED_COUNT = FAILED_COUNT + 1 ))
fi

TEST_NAME="wc2"
RESULT=`../get-summits-locators.bash files/region.tmp | grep -cP '\w+/\w+-\d+ \w\w\d\d\w\w'`
if [ $RESULT -eq 74 ]
then
echo Test \'$TEST_NAME\' PASSED
(( PASSED_COUNT = PASSED_COUNT + 1 ))
else
echo Test \'$TEST_NAME\' FAILED
(( FAILED_COUNT = FAILED_COUNT + 1 ))
fi

TEST_NAME="wc3"
RESULT=`../get-summits-locators.bash files/region.tmp | grep -cPv '\w+/\w+-\d+ \w\w\d\d\w\w'`
if [ $RESULT -eq 0 ]
then
echo Test \'$TEST_NAME\' PASSED
(( PASSED_COUNT = PASSED_COUNT + 1 ))
else
echo Test \'$TEST_NAME\' FAILED
(( FAILED_COUNT = FAILED_COUNT + 1 ))
fi

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

