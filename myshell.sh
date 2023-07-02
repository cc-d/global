#!/bin/sh
echo 'loading myshell.sh'

# Load all my posix compliant functions
if [ -f "$HOME/global/funcs.sh" ]; then
    export GLOBALDIR="$HOME/global"
    export PATH="$GLOBALDIR:$PATH"
fi

# List only directories
dirsonly() {
    curdirs=$(command ls -A -p --color=always . | grep '/$' | tr '\n' ' ')
    echo -n "$curdirs "
}

# List only hidden directories
hid_dirsonly() {
    hid_dirs=$(command ls -A -p --color=always . | grep '/$' | grep '^\.\/' | tr '\n' ' ')
    echo -n "$hid_dirs "
}

# List only hidden files
hidsonly() {
    curhids=$(command ls -A -p --color=always . | grep -v '/$' | grep '^\.' | tr '\n' ' ')
    echo -n "$curhids "
}

# List only regular files
filesonly() {
    curfiles=$(command ls -A -p --color=always . | grep -v '/$' | grep -v '^\.' | tr '\n' ' ')
    echo -n "$curfiles "
}

# Common shell utility overrides
ls() {
    hid_dirsonly
    dirsonly
    hidsonly
    filesonly
    echo -n '\n\n'
}

cd() {
    builtin cd "$@" && ls
}



echo 'myshell.sh loaded completely'
