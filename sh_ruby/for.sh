#!/bin/sh

for time in moring noon afternoon evening; do
    echo "It's ${time}"
done

s=0
for ((i=1;i<=100;i=i+1));do
    s=$(($s + $i))
done

echo "for sum is: ${s}"


sum=0
j=1
while [ $j -le 100 ];do
    sum=$(($j + $sum))
    j=$(($j + 1))
done

echo "while sum is:${sum}"


total=0
k=1

until [ $k -gt 100 ]; do
    total=$(($total + $k))
    k=$(($k + 1))
done

echo "until sum is: ${total}"