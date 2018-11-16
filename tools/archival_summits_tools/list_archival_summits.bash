y=1
for i in {01..79}
do
x=$(sed -n "$i p" summits.num)
echo x: $x y: $y
if [ $x -ne $y ]
then
echo ta liczba: $y
y=$(( $y + 1 ))
fi
y=$(( $y + 1 ))
done
