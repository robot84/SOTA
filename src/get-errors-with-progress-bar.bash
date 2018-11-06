#!/bin/bash

main(){
  INPUT_FILE=sota.tmp
  cat - | awk -F, ' {print $3,$4,$5,$6,$8,$10}' > $INPUT_FILE
  ROUNDS=`cat $INPUT_FILE | wc -l`
  
  echoerr $ROUNDS
  
  create_progress_bar $ROUNDS
  main_loop
}


main_loop(){
  let i=0
  while read SUMMIT D4 D5 D6 CALLSIGN D10;
  do
    do_all
    update_progress_bar
  done <$INPUT_FILE
  rm $INPUT_FILE
}

do_all() {
  SUMMIT_QTH=`cat SP-BZ-QTH-Locators.txt | grep "$SUMMIT" | awk '{print $2}'`
  CALLSIGN_QTH=`cat SP-chasers-locators.txt | grep "$CALLSIGN" | awk '{print $2}'`
  
  
  if [[ -z $CALLSIGN_QTH ]]
  then
    echo "No callsign $CALLSIGN in database"
    #echo  "Error when processing QSO from $SUMMIT ($SUMMIT_QTH) with $CALLSIGN ($CALLSIGN_QTH) $D4 $D5 $D6 Notes: $D10"
  fi
  
  if [[ $CALLSIGN_QTH = "??????" ]];
  then
    echo "Callsign $CALLSIGN has no QTH Locator in database"
  fi
}

echoerr() { echo "$@" 1>&2; }

create_progress_bar(){
  PROGRESS_BAR_COUNTER=0
  let "ONE_PERCENT_IS = $ROUNDS / 100"
  let "TWO_PERCENTS_IS = $ONE_PERCENT_IS * 2"
  echoerr $ONE_PERCENT_IS
  echoerr $TWO_PERCENTS_IS
  
  echoerr -ne "|#"
  
  for VAR in {1..22}
  do
    echoerr -ne " "
  done
  
  echoerr -ne "."
  
  for VAR in {1..23}
  do
    echoerr -ne " "
  done
  
  echoerr -ne "|\r"
}

update_progress_bar(){
  if [ $PROGRESS_BAR_COUNTER -gt $TWO_PERCENTS_IS ];
  then
    echoerr -ne "#"
    PROGRESS_BAR_COUNTER=0
  else
    let "PROGRESS_BAR_COUNTER = $PROGRESS_BAR_COUNTER + 1"
  fi
}




main "$@"
