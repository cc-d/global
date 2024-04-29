#!/bin/sh
export _LGS='[GSHELL]>'

# get local cc-d/global repo path so no path weirdness happens
export MYGLOBALDIR="$HOME/global"
export GSHELLDIR="$MYGLOBALDIR/globalshell"
INIT_COMMAND=". $MYGLOBALDIR/init-globalshell.sh"
export GLOBAL_SHELL_HISTORY=1

# Add globalshell init to zshrc/bashrc depending on system type
# make sure the init command added is in the EXACT same format
# as $INIT_COMMAND to prevent infinite loops
add_init_to_rc_file() {
  RC_FILE="$1"
  if [ ! -f "$RC_FILE" ]; then
    echo "$INIT_COMMAND" > "$RC_FILE"
    echo "$_LGS Created $RC_FILE with init command"
  elif ! grep -qxF "$INIT_COMMAND" "$RC_FILE"; then
    echo "$INIT_COMMAND" >> "$RC_FILE"
    echo "$_LGS Added init to $RC_FILE"
  fi
}

# Add globalshell init to zshrc/bashrc depending on system type
if [ "$(basename "$SHELL")" = "zsh" ]; then
  add_init_to_rc_file "$HOME/.zshrc"
elif [ "$(basename "$SHELL")" = "bash" ]; then
  add_init_to_rc_file "$HOME/.bashrc"
fi

# import aliases
. "$GSHELLDIR/aliases.sh"

# import our functions
# always source utils first
. "$GSHELLDIR/funcs/utils.sh"

for f in $(find "$GSHELLDIR/funcs" -type f -name '*.sh'); do
  . $f
done

# builtin command overrides/aliases/etc
# if ls receives any args it behaves as normal

alias ls='ls -AaFp --color=always'


cd () {
    if which builtin &>/dev/null; then
        builtin cd $@
    else
        command cd $@
    fi

    if [ "$(uname -m)" = "x86_64" ]; then
        ls -Aa1Fp --color=always | tr '\n' ' ' | "$GSHELLDIR/colorprint-amd64"
    else
        ls -Aa1Fp --color=always | tr '\n' ' ' | "$GSHELLDIR/colorprint-arm"
    fi
    echo ''
}

globalshell () {
  echo "$_LGS GLOBAL SHELL COMMANDS"
  echo ""
  echo "actvenv columnate dirfiles dirfiles evar"
  echo "fixperms gitacpush gitconf gitdatecommit gitnewbranch"
  echo "git_ssh gptfiles history ostype pasterun"
  echo "publish_to_pypi revert_to_commit safesorce screenproc"
  echo "sourceshell pytime"
  echo ""
}

# automatically run git_ssh if the environment variable is set
if [ -n "$GIT_SSH_DEFAULT_CHOICE" ]; then
  echo "$_LGS GIT_SSH_DEFAULT_CHOICE is set, running git_ssh"
  git_ssh
fi

echo "$_LGS GLOBAL SHELL INITIALIZED\n"
