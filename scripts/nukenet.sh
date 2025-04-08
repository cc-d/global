#!/bin/sh

get_ifaces() {
    echo `ifconfig -a | cut -f 1 -w | grep -vE \'^\$\' | sed -E 's/:$//g'`
}

main() {
    for i in `get_ifaces`; do
        echo "$i $1"
        ifconfig $i $1;

    done
}



if [ "$2" = "loop" ]; then
    while true; do
        main $1
        sleep 0.05
    done
else
    main $1
fi