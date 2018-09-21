#
# This script extract summits' QTH locators
#
# Robert Zabkiewicz (c) 2018
# Version 0.0.3
#
# Usage:
# 1. go to below web site in your web browser
#	http://sotadata.org.uk/summits.aspx
# 2. Set desired Assosiation and Region
# 3. Click Submit
# 4. copy and paste table of summits from this site to text file and name it locators.txt
# 5. use commands wrote out below on this file
sed 's/ /_/g' locators.txt > 1.txt
cat 1.txt | awk '{print $1, $7}'
