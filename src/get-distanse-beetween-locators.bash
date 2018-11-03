#!/bin/bash
#
#
#
QTH_LOCATOR_PATTERN="[A-Za-z][A-Za-z][0-9][0-9][A-Za-z][A-Za-z]"
SHORT_FORMAT_ENABLED=no
MILES_AS_UNIT=no
CACHE_ENABLED=no
VERBOSE_ENABLED=no
DISTANCES_CACHE_FILE="${HOME}.distance_cache"

function print_debug_msg() {
[ $VERBOSE_ENABLED = "yes" ] && echo "$1"
}


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
						echo "${0##*/} [-s] [-m] [-c] [-v] [-cf cache_file] <QTHlocator1> <QTHlocator2>"
						echo
						echo -e " -s|--short\t short output format, prints only distance"
						echo -e " -m|--miles\t use with -m, print in miles insted of km"
						echo -e " -c|--cache-enabled\t Enable responses caching."
						echo -e "\t\tWith cache enabled you don't need to query a server another time\
							for the same query"
						echo -e " -cf|--cache-file\t use cache file for caching queries"
						echo -e " -v|--verbose\t print info about app work"
						exit 1 
						;;
				-v|--verbose)
					VERBOSE_ENABLED=yes
					shift
					;;
				-s|--short)
					SHORT_FORMAT_ENABLED=yes
					print_debug_msg "Short format enabled."
					shift
					;;
				-m|--miles)
					MILES_AS_UNIT=yes
					print_debug_msg "US miles as unit enabled."
					shift
					;;
				-c|--cache)
				CACHE_ENABLED=yes
					print_debug_msg "Work with cache enabled."
				shift
				;;
				-cf|--cache-file)
				DISTANCES_CACHE_FILE="$2"
				CACHE_ENABLED=yes
				shift
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
					qth1="${POSITIONAL[0]}" 
					qth2="${POSITIONAL[1]}" 
}


		function check_if_callsigns_have_valid_format() {
		if [[ "$1" =~ $QTH_LOCATOR_PATTERN ]] && [[ "$2" =~ $QTH_LOCATOR_PATTERN ]]
			then
		:
		else
			echo "Error: QTHlocator must be 6 characters length and in format AB01CD"
			echo "This is not case-sensitive"
				exit 1
				fi


		}

function init_cache() {
	[ $CACHE_ENABLED = "yes" ] && \
	[ ! -e "$DISTANCES_CACHE_FILE" ] && \
	( mkdir -p $(dirname "$DISTANCES_CACHE_FILE"); \
	touch  "$DISTANCES_CACHE_FILE"; \
	print_debug_msg "Creating cache file $DISTANCES_CACHE_FILE"; )

	print_debug_msg "Init cache with $DISTANCES_CACHE_FILE"
}


function check_cache() {
	if [ $CACHE_ENABLED = "yes" ]
		then
			array=($(grep -E "(^$qth1 $qth2 )|(^$qth2 $qth1 )" "$DISTANCES_CACHE_FILE"))
			if [ ${#array[*]} -eq 4 ]
				then
					print_debug_msg "Distance found in cache. Values are ${array[0]}  ${array[1]}  ${array[2]}  ${array[3]}."
					distance_km=${array[2]}
					distance_miles=${array[3]}
					RESULT_DATA="Distance between ${array[0]} & ${array[1]} is ${array[2]} km (${array[3]} miles)"

					return 0
					else
					print_debug_msg "Distance NOT found in cache."

					return 1
					fi
			else
				return 1
					fi
}

function write_to_cache() {
if [ $CACHE_ENABLED = "yes" ]
then
grep -qE "($qth1 $qth2 )|(^$qth2 $qth1 )" "$DISTANCES_CACHE_FILE"
if [ $? -ne 0 ]
then
[ "$qth1" \< "$qth2" ] &&  echo $qth1 $qth2 $distance_km $distance_miles >> "$DISTANCES_CACHE_FILE"
[ "$qth1" \> "$qth2" ] &&  echo $qth2 $qth1 $distance_km $distance_miles >> "$DISTANCES_CACHE_FILE"
print_debug_msg "Writing distance to cache file."
fi
fi
}


function calculate_distance() {
print_debug_msg "Calculating distance...Please wait..."
				TMP_FILE=$(mktemp)
				curl -s -X POST --data "mygrid=$1&fagrid=$2" https://www.chris.org/cgi-bin/showdis > "$TMP_FILE"
				RESULT_DATA=`cat "$TMP_FILE" | grep "Distance between"  | grep -o ".*," | tr -d "," `
				rm -f  "$TMP_FILE"
				distance_km=$(echo $RESULT_DATA | awk '{print $7}')
				distance_miles=$(echo $RESULT_DATA | awk '{print substr($9,2)}')
}


function print_distance() {
				if [ $SHORT_FORMAT_ENABLED = "yes" ]
					then
						if [ $MILES_AS_UNIT = "yes" ]
							then
								echo $distance_miles
						else
							echo  $distance_km
								fi
				else

					echo $RESULT_DATA
						fi

}


		parse_parameters $@
		check_if_callsigns_have_valid_format $qth1 $qth2
		init_cache
		check_cache
		[ $? -eq 0 ] || calculate_distance $qth1 $qth2
		write_to_cache $qth1 $qth2
		print_distance
