#!/bin/sh

listdir() {
    dirtree=$(find "$1" -print | sed -e '1d' -e 's;[^/]*/;  ;g' -e 's;^  ;;')
    echo "$dirtree" | grep -vE '.pyc$'

}
