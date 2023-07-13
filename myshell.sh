#!/bin/sh
EL='[ GLOBALSHELL ]: '

# get local cc-d/global repo path so no path weirdness happens
export MYGLOBALDIR="$HOME/global"

# import aliases
. "$MYGLOBALDIR/aliases.sh" && echo "$EL imported alises.sh from $MYGLOBALDIR"

# import our functions
. "$MYGLOBALDIR/funcs.sh" && echo "$EL imported funcs.sh from $MYGLOBALDIR"

# builtin command overrides/aliases/etc
# if ls receives any args it behaves as normal

alias ls='ls -AaFp --color=always'

cd () {
    builtin cd "$@";
    if [ "$(uname -m)" = "x86_64" ]; then
        ls -AamFp --color=always | sed 's/, / /g' | sed 's/,$//' | "$MYGLOBALDIR/colorprint-x86";
    else
        ls -AamFp --color=always | sed 's/, / /g' | sed 's/,$//' | "$MYGLOBALDIR/colorprint";
    fi
    echo ''
}


echo "$EL myshell.sh loaded completely"
echo ''
