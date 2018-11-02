#!/bin/sh
function sum(){
    # $0 不是函数名, 而是整个命令的名. 和函数外面的$0一样????
    echo $0

    echo $1
    echo $2
    s=0
    for ((i=1;i<=$1;i=i+1));do
        s=$(($i + $s))
    done
    
    echo "sum is:${s}"
}


echo `pwd`
y=$(echo $1 | sed 's/[0-9]//g')

if [ -z "${y}" ];then
    sum $1
else
    echo "Error: $1 is not a number"
fi