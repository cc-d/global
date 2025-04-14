#!/bin/sh

_WP_SLEEP=1

if [ -z "$1" ]; then
    _WP_SLEEP="$1";
fi

 while true; do
    _temp=`sudo wdutil info | grep 'RSSI' | grep -oE '[-0-9]+'`
    echo "$_temp `date "+%Y-%m-%dT%H:%M:%S"`";
done