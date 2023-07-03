#!/bin/sh
echo 'loading myshell.sh'

# Load all my posix compliant functions
if [ -f "$HOME/global/funcs.sh" ]; then
    export GLOBALDIR="$HOME/global"
    export PATH="$GLOBALDIR:$PATH"
    . "$GLOBALPATH/funcs.sh"
fi


# builtin command overrides/aliases/etc
# if ls receives any args it behaves as normal

ls() {
    if [ $# -gt 0 ]; then
        command ls "$@"
    else
        alldirfiles
    fi
}



    echo 'myshell.sh loaded completely'
