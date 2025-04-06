#!/bin/sh

get_ifaces() {
    echo `ifconfig -a | cut -f 1 -w | grep -vE \'^\$\' | sed -E 's/:$//g'`
}

main() {
    for i in `get_ifaces`; do
        ifconfig $i $1;
    done
}

main $1