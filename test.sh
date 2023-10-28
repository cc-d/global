#!/bin/sh


dirfiles() {
    _LDDIR="$1"

    # Print the directory name
    echo "$2$(basename $_LDDIR)/"

    # List files in the current directory
    curfiles=""
    for f in $(find "$_LDDIR" -maxdepth 1 -mindepth 1 -type f \
    -not -name '*.pyc' ); do
        curfiles="$curfiles `basename $f`"
    done
    echo "$2$curfiles"

    # Recursively list files in subdirectories
    for d in $(find "$_LDDIR" -maxdepth 1 -mindepth 1 -type d \
    -not -name '__pycache__' -not -name 'venv'); do
        listdirfiles "$d" "$2  "
    done
}

# Call the function with the dire