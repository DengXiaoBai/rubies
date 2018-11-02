#!/bin/sh
read -t 30 -p "Plz choose [yes/no]:" choose

case ${choose} in
    "yes")
        echo "yes !!!!"
        ;;
    "no")
        echo "oh no !!!"
        ;;
    *)
    echo " error"
    ;;
esac