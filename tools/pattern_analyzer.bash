#!/bin/bash
output_file=$(mktemp)
while read word
do
# echo $word
len=${#word}
for i in $(seq 0 $(( $len - 1 )) )
do
znak=${word:$i:1}
[[ $znak =~ [A-Za-z] ]] && echo -n "[A-Z]" >> "$output_file" || \
( [[ $znak =~ [0-9] ]] && echo -n "[0-9]" >> "$output_file" || \
echo -n "$znak" >> "$output_file" )
done
echo  "" >> "$output_file" 
done
cat "$output_file" | sort | uniq -c | sort -nr
rm $output_file
