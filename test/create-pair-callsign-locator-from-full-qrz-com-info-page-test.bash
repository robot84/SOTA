#!/bin/bash

t001_cookie_validation() {


rm -f ../SO9ARC/database/SQ9KCN.log
cp "$CHASERS_QTH_LOCATORS_FILE" /tmp/chasers_locators.backup
../src/get-callsign-info-page.bash SQ9KCN >> /dev/null
../src/create-pair-callsign-locator-from-full-qrz-com-info-page.bash > /dev/null
cat "$CHASERS_QTH_LOCATORS_FILE" | grep 'SQ9KCN KO00ac' >> /dev/null \
&& echo Passed || echo Failed
cp /tmp/chasers_locators.backup "$CHASERS_QTH_LOCATORS_FILE" 
rm /tmp/chasers_locators.backup
}


main() {
cd $(dirname $0)/
. ../src/load_config_file.bash
t001_cookie_validation
}

main 
