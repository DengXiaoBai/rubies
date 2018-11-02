#!/bin/sh
read -t 30 -p "plz input your name:" name
echo "\nname:$name"

read -s -t 30 -p "plz input your age:" age
echo "\nage:$age"

read -n 1 -t 30 -p "plz input your gender[M/F]:" gender
echo "\nsex:$gender"
