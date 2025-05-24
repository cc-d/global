#!/bin/sh

hashdir() {
    if echo $1 | grep -Ei 'sha|md5'; then 
        _hashbin=$1; 
        shift;
        echo "echo $1"
    else
        _hashbin=sha256
    fi
    if [ $# -gt 1 ]; then
        find $@
    else
        find $1 -type f -exec "$_hashbin" {} \;
    fi

}
