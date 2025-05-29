#!/bin/sh


GLOBAL_SHELL_DIR=$(dirname $(realpath `dirname $0`))


_NN_OUTFILE=/tmp/nnsh_`$GLOBAL_SHELL_DIR/misc/time/time.arm64`

_nn_get_ifaces() {
    echo `ifconfig -a | cut -f 1 -w | grep -vE \'^\$\' | sed -E 's/:$//g'`
}

_nn_ifconfig() {
    for i in `_nn_get_ifaces`; do
        echo "$i $1"
        ifconfig $i $1;

    done

    echo `$GLOBAL_SHELL_DIR/misc/time/time.arm64` >> $_NN_OUTFILE;
}


if [ "$2" = "loop" ]; then
    while true; do
        _nn_ifconfig $1
        sleep 0.5
    done
else
    _nn_ifconfig $1
fi

