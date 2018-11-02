#!/bin/bash

t001_cookie_validation() {

rm SO9ARC/database/SQ9KCN.log
src/get-callsign-info-page.bash SQ9KCN >> /dev/null
src/create-pair-callsign-locator-from-full-qrz-com-info-page.bash SQ9KCN | \
grep '??????' >> /dev/null \
&& echo Failed || echo Passed
}

t002_cookie_validation() {

rm SO9ARC/database/SQ9KCN.log
src/get-callsign-info-page.bash SQ9KCN >> /dev/null
src/create-pair-callsign-locator-from-full-qrz-com-info-page.bash SQ9KCN | \
grep 'SQ9KCN KO00ac' >> /dev/null \
&& echo Passed || echo Failed
}


main() {
cd $(dirname $0)/..
. resources/config.cfg

t001_cookie_validation
t002_cookie_validation
}

main 
