#!/bin/bash
# 
html2text -width 130 *.html | tr "_" " "  | grep " |" | grep -v "|SOTA" |grep -v "Ref" |awk -F"|" '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10 }' 
