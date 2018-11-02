#!/bin/sh
echo "executing $0"
echo "parameters num: $#"
echo "parameters are treated as one: $*"
echo "parameters are seperate : $@"

for i in "$*"
 do
   echo "the parameters is : $i"
 done

x=1

for y in "$@"
 do
   echo "the $x  parameter is :$y"
   x=$(($x + 1))
 done

num1=$1
num2=$2
sum=$(($num1+$num2))
echo "sum is ${sum}"

