#!/bin/sh
read -p "Plz input your file name:" file

if [ -z "${file}" ]; then
    echo "Error: input is empty"
    exit 1
elif [ ! -e "${file}" ]; then
    echo "Error: file not exist"
    exit 2
elif [ -f "${file}" ]; then
    echo "${file} is a File"
elif [ -d "${file}" ]; then
    echo "${file} is a Dir"
else
    echo "${file} is shit"
fi