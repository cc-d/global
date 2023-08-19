#!/bin/sh
EL='[ GLOBALSHELL ]: '

# get local cc-d/global repo path so no path weirdness happens
export MYGLOBALDIR="$HOME/global"
export GSHELLDIR="$MYGLOBALDIR/shell"

# import aliases
. "$GSHELLDIR/aliases.sh" && echo "$EL imported alises.sh from $GSHELLDIR"

# import our functions
. "$GSHELLDIR/funcs.sh" && echo "$EL imported funcs.sh from $GSHELLDIR"

# builtin command overrides/aliases/etc
# if ls receives any args it behaves as normal

alias ls='ls -AaFp --color=always'

cd () {
    builtin cd "$@";
    if [ "$(uname -m)" = "x86_64" ]; then
        ls -Aa1Fp --color=always | tr '\n' ' ' | "$GSHELLDIR/colorprint-x86";
    else
        ls -Aa1Fp --color=always | tr '\n' ' ' | "$GSHELLDIR/colorprint-arm";
    fi
    echo ''
}


echo "$EL myshell.sh loaded completely"
echo ''
