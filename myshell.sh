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
    ls -AamFp --color=always | python3 "$MYGLOBALDIR/colorprint.py";
    echo ''
}


echo "$EL myshell.sh loaded completely"
echo ''
