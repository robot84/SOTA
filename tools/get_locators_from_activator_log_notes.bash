#!/bin/bash
# First method
# cat SO9ARC-all-qsos.csv | grep -P "\w\w\d\d\w\w" | cut -d, -f8- | sed 's/,,/ /' | sed -r "s/([[:alpha:]]{2}[[:digit:]]{2}[[:alpha:]]{2})|(^\S*)/,&,/g" |  cut -d, -f2,4 | tr  "," " "

#Second - alternate method
#cat SO9ARC-all-qsos.csv  | grep -P "\w\w\d\d\w\w" | cut -d, -f8- | sed 's/,,/ /' | sed -E 's/(\w*) (.*)([[:alpha:]]{2}[[:digit:]]{2}[[:alpha:]]{2})(.*)/\1 \3/'



SHOW_ONLY_ENABLED=no
ACTIVATOR_LOG=""

function parse_parameters() {
 POSITIONAL=()
  while [[ $# -gt 0 ]]
  do
    key="$1"
    
    case $key in
      -h|--help)
        echo "Usage: ${0##*/} [-s] <activator_log_file.csv>"
        echo "Searching QTH Locators for callsigns in report notes of activator's log."
        echo
		echo -e "      -s|--show-only\t\t only show locators found in activator log. Do not add them to database"
		echo -e "      --help\t\t\t display this help and exit"
		echo -e "      --version\t\t\t output version information and exit"
        exit 1
      ;;
     --version)
		print_version_info
        exit
      ;;
	  -s|--show-only)
	  SHOW_ONLY_ENABLED=yes
	  shift
	  ;;
      -*)
        echo "$0: invalid option -- '$1'"
        echo "Try '$0 --help' for more information."
        exit
      ;;
      *)
        POSITIONAL+=("$1") # save it in an array for later
        shift
      ;;
    esac
  done
  set -- "${POSITIONAL[@]}" # restore positional parameters

  ACTIVATOR_LOG="${POSITIONAL[0]}"

   if [ "$#" -lt 1 ]
  then
    echo "$0: Mandatory argument ommited."
    echo "Try '$0 --help' for more information."
    f_log_msg "$ERROR_LOG_FILE" "No activator log passed to script."
    exit 1
  fi
}


function change_all_letters_in_file_to_uppercase() {
sed -ibackup -e 's/.*/\U&/' "$1"
}


function create_file_with_all_callsigns_which_have_locators_written_in_notes_field_in_activator_log() {
local activator_log="$1"
local output_file="$2"
if_file_exists "$activator_log" "activator log"
cat "$activator_log" | \
grep -P "\w\w\d\d\w\w" | cut -d, -f8- | sed 's/,,/ /' | sed -r "s/([[:alpha:]]{2}[[:digit:]]{2}[[:alpha:]]{2})|(^\S*)/,&,/g" |  cut -d, -f2,4 | tr  "," " " | grep -v "/" | sort | uniq | \
tr "[[:lower:]]" "[[:upper:]]" > "$output_file"
}


function main() {

file_with_all_callsigns_with_locator_in_notes_field_from_activator_log=$(mktemp)
create_file_with_all_callsigns_which_have_locators_written_in_notes_field_in_activator_log "$ACTIVATOR_LOG" "$file_with_all_callsigns_with_locator_in_notes_field_from_activator_log"
change_all_letters_in_file_to_uppercase "$file_with_all_callsigns_with_locator_in_notes_field_from_activator_log"
change_all_letters_in_file_to_uppercase "$CHASERS_QTH_LOCATORS_FILE"

if [ $SHOW_ONLY_ENABLED = "yes" ]
then
cat "$file_with_all_callsigns_with_locator_in_notes_field_from_activator_log"
exit 0
fi


while read qra qth
do
	grep $qra "$CHASERS_QTH_LOCATORS_FILE" > /dev/null || \
	{ 
	echo "No $qra in database... Adding..."
	echo $qra $qth >> "$CHASERS_QTH_LOCATORS_FILE" 
	}
done < "$file_with_all_callsigns_with_locator_in_notes_field_from_activator_log"

rm $file_with_all_callsigns_with_locator_in_notes_field_from_activator_log
}

this_script_dir=$(dirname $0)
. "$this_script_dir/../src/common_functions"
load_config_file "$this_script_dir"
parse_parameters $@
main
