#!/bin/bash
#
#
#
QTH_LOCATOR_PATTERN="[A-Za-z][A-Za-z][0-9][0-9][A-Za-z][A-Za-z]"
SHORT_FORMAT_ENABLED=no
MILES_AS_UNIT=no

function parse_parameters(){
	if [ "$#" -lt 2 ]
		then
			echo "$0: too less parameters."
			echo "Run $0 --help for more info."
			exit 1
			fi

			POSITIONAL=()
			while [[ $# -gt 0 ]]
				do
					key="$1"

						case $key in
						-h|--help)
						echo ""
						echo "Usage:"
						echo "${0##*/} [-s] [-m] <QTHlocator1> <QTHlocator2>"
						echo
						echo -e " -s|--short\t short output format, prints only distance"
						echo -e " -m|--miles\t use with -m, print in miles insted of km"
						exit 1 
						;;
				-s|--short)
					SHORT_FORMAT_ENABLED=yes
					shift
					;;
				-m|--miles)
					MILES_AS_UNIT=yes
					shift
					;;
				-*)
					echo "${0##*/}: invalid option -- '$1'"
					echo "Try '$0 --help' for more information."
					exit 1
					;;
				*)
					POSITIONAL+=("$1") # save it in an array for later
					shift
					;;
				esac
					done

					set -- "${POSITIONAL[@]}" # restore positional parameters
}


function calculate_distance() {
	TMP_FILE=$(mktemp)
		if [[ "$1" =~ $QTH_LOCATOR_PATTERN ]] && [[ "$2" =~ $QTH_LOCATOR_PATTERN ]]
			then
				curl -s -X POST --data "mygrid=$1&fagrid=$2" https://www.chris.org/cgi-bin/showdis > "$TMP_FILE"
		else
			echo "Error: QTHlocator must be 6 characters length and in format AB01CD"
				exit 1
				fi

				RESULT_DATA=`cat "$TMP_FILE" | grep "Distance between"  | grep -o ".*," | tr -d "," `

				if [ $SHORT_FORMAT_ENABLED = yes ]
					then
						if [ $MILES_AS_UNIT = yes ]
							then
								echo $RESULT_DATA | awk '{print substr($9,2)}'
						else
							echo $RESULT_DATA | awk '{print $7}'
								fi
				else

					echo $RESULT_DATA
						fi

}


		parse_parameters $@
		calculate_distance "${POSITIONAL[@]}"
