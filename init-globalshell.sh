#!/bin/sh
EL='[ GLOBALSHELL ]: '

# get local cc-d/global repo path so no path weirdness happens
export MYGLOBALDIR="$HOME/global"
export GSHELLDIR="$MYGLOBALDIR/globalshell"
INIT_COMMAND=". $MYGLOBALDIR/init-globalshell.sh"

# Add globalshell init to zshrc/bashrc depending on system type
# make sure the init command added is in the EXACT same format
# as $INIT_COMMAND to prevent infinite loops
add_init_to_rc_file() {
  RC_FILE="$1"
  if [ ! -f "$RC_FILE" ]; then
    echo "$INIT_COMMAND" > "$RC_FILE"
    echo "$EL Created $RC_FILE with init command"
  elif ! grep -qxF "$INIT_COMMAND" "$RC_FILE"; then
    echo "$INIT_COMMAND" >> "$RC_FILE"
    echo "$EL Added init to $RC_FILE"
  else
    echo "$EL Init already present in $RC_FILE"
  fi
}

# Add globalshell init to zshrc/bashrc depending on system type
if [ "$(basename "$SHELL")" = "zsh" ]; then
  add_init_to_rc_file "$HOME/.zshrc"
elif [ "$(basename "$SHELL")" = "bash" ]; then
  add_init_to_rc_file "$HOME/.bashrc"
fi

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
