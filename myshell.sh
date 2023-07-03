#!/bin/sh
echo 'loading myshell.sh'

# Load all my posix compliant functions
if [ -f "$HOME/global/funcs.sh" ]; then
    export GLOBALDIR="$HOME/global"
    export PATH="$GLOBALDIR:$PATH"
    . "$HOME/global/funcs.sh"
fi


# builtin command overrides/aliases/etc
# if ls receives any args it behaves as normal

ls() {
    if [ $# -eq 0 ]; then
        alldirfiles
    else
        command ls "$@"
    fi
}



echo 'myshell.sh loaded completely'
