#!/bin/sh
EL='[ GLOBALSHELL ]: '

# get local cc-d/global repo path so no path weirdness happens
export MYGLOBALDIR=$(echo $0 | sed 's/myshell.sh$//')

# import aliases
. "$MYGLOBALDIR/aliases.sh" && echo "$EL imported alises.sh from $MYGLOBALDIR"

# import our functions
. "$MYGLOBALDIR/funcs.sh" && echo "$EL imported funcs.sh from $MYGLOBALDIR"

# builtin command overrides/aliases/etc
# if ls receives any args it behaves as normal

alias ls='ls -AaFG'

cd () {
    builtin cd "$@";
    echo $(ls -AamFp --color=always | sed 's/, / /g') && echo ''
}


echo "$EL myshell.sh loaded completely\n"