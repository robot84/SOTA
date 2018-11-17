function parse_parameters() {
	if [ "$#" -lt 1 ]
		then
			echo
			echo "Usage:"
			echo "$0 <region-info-file-name>"
			echo
			echo "Please pass as the argument name of a file containing information about summits"
			echo "in format:"
			echo "OK/PO-001 JO90wa"
			echo "OK/PO-002 JN99aa"
			echo " ... "
			echo ""
			echo "You can use resource/summits_database.dat file"
			exit 1
			fi
}


parse_parameters $@
declare -i last_num=0
declare -i new_num=0
input_file="$1"
lines=$(cat "$input_file" | wc -l)
ref_prefix=$(sed -rn "1 s/[[:digit:]]{3} .*//p" "$input_file")
for i in $(seq 1 $lines)
do
new_num=10#$(sed  -rn "$i s/.*([[:digit:]]{3}).*/\1/p" "$input_file")
# echo new: $new_num last: $last_num
if [ $new_num -ne $(( $last_num + 1 )) ]
then
# echo last1 $(( $last_num + 1 )) new $(( $new_num - 1 ))
for ii in $(seq $(( $last_num + 1 )) $(( $new_num - 1 )) )
do
printf "%s%03d\n" $ref_prefix $ii
# printf "%s%03u\n" $ref_prefix $(( $y + 1 ))
done
fi
last_num=$new_num
done
