#!/bin/sh
echo "executing $0, the pid is $$"
echo $(pwd)
echo $(find . -name "predefine.s"h)
find $(pwd) -name predefine.sh &
echo "the last one Daemon process is $!"

