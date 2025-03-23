#!/bin/sh

# left text for globalshell messages
export _GLOBAL_SHELL_LEFT='[GLOBALSHELL]'

# Assumes repo is cloned to $HOME/global
export GLOBAL_SHELL_DIR="$HOME/global"
INIT_COMMAND=". $GLOBAL_SHELL_DIR/init-globalshell.sh"

export GLOBAL_SHELL_GS_DIR="$GLOBAL_SHELL_DIR/globalshell"
export GLOBAL_SHELL_HISTORY=1

# Path Stuff
export GLOBAL_BIN_PATH="$GLOBAL_SHELL_DIR/bin"
export PATH="$GLOBAL_BIN_PATH:$PATH"

# Add globalshell init to zshrc/bashrc depending on system type
if echo "$SHELL" | grep -q 'zsh'; then
  export GLOBAL_SHELL_RC_FILE="$HOME/.zshrc"
elif echo "$SHELL" | grep -q 'bash'; then
  export GLOBAL_SHELL_RC_FILE="$HOME/.bashrc"
else
  echo "No Shell .rc file detected"
fi
# Add globalshell init to zshrc/bashrc depending on system type
# make sure the init command added is in the EXACT same format
# as $INIT_COMMAND to prevent infinite loops
add_init_to_rc_file() {
  RC_FILE="$1"
  if [ ! -f "$RC_FILE" ]; then
    echo "$INIT_COMMAND" > "$RC_FILE"
    echo "$_GLOBAL_SHELL_LEFT Created $RC_FILE with init command"
  elif ! cat "$RC_FILE" | grep -q "$INIT_COMMAND"; then
    echo "$INIT_COMMAND" >> "$RC_FILE"
    echo "$_GLOBAL_SHELL_LEFT Added init to $RC_FILE"
  else
    echo "$_GLOBAL_SHELL_LEFT Init command already in $RC_FILE"
  fi
}


add_init_to_rc_file "$GLOBAL_SHELL_RC_FILE"

# import aliases
. "$GLOBAL_SHELL_GS_DIR/aliases.sh"

# import our functions, always source utils first
. "$GLOBAL_SHELL_GS_DIR/funcs/utils.sh"

# For shell.sh init
. "$GLOBAL_SHELL_GS_DIR/funcs/mac.sh"

# source all functions in funcs directory
for f in $(find "$GLOBAL_SHELL_GS_DIR/funcs" -type f -name '*.sh' -not -name 'utils.sh' -not -name 'shell.sh'); do
    . $f
done

# builtin command overrides/aliases/etc
# if ls receives any args it behaves as normal


cd () {
    if which builtin &>/dev/null; then
        builtin cd $@
    else
        command cd $@
    fi

    if [ "$(uname -m)" = "x86_64" ]; then
        ls -Aa1Fp --color=always | tr '\n' ' ' | sed -E 's/^.*\.\.[^ ]* //' |  "$GLOBAL_SHELL_GS_DIR/colorprint-amd64"
    elif echo "$(uname -m)" | grep -q 'arm'; then
        ls -Aa1Fp --color=always | tr '\n' ' ' | sed -E 's/^.*\.\.[^ ]* //' | "$GLOBAL_SHELL_GS_DIR/colorprint-arm"
    else
        ls -Aa1Fp --color=always | tr '\n' ' ' | sed -E 's/^.*\.\.[^ ]* //'
    fi

    echo ''
}

globalshell () {
  echo "$_GLOBAL_SHELL_LEFT FUNCTIONS:"
  _all_gc_funcs="globalshell\n"
  _gs_grep_cmd='^[a-zA-Z0-9_-]+[[:space:]]*\(\)[[:space:]]*{$'
  for f in $(find "$GLOBAL_SHELL_GS_DIR/funcs" -type f -name '*.sh'); do

    _cur_gc_funcs=$(cat $f | grep -E "$_gs_grep_cmd" | sed -E 's/[{}()]//g')
    if [ -n "$_cur_gc_funcs" ]; then
      _all_gc_funcs="$_all_gc_funcs\n$_cur_gc_funcs"
    else
      _all_gc_funcs="$_cur_gc_funcs"
    fi

  done
  _all_gc_funcs=$(echo "$_all_gc_funcs" | sort | uniq)
  _all_gc_funcs=$(echo "$_all_gc_funcs" | tr '\n' ' ' | sed -E 's/[[:space:]]+/ /g' | sed -E 's/^ //')
  echo "$_all_gc_funcs"
  echo ""


  echo "$_GLOBAL_SHELL_LEFT ALIASES:"
  _all_gc_aliases=$(cat "$GLOBAL_SHELL_GS_DIR/aliases.sh" | grep -oE '^alias [^=]*' | sed -E 's/alias //g' | tr '\n' ' ')
  echo "$_all_gc_aliases"
  echo ""

  echo "$_GLOBAL_SHELL_LEFT BIN:"
  _all_gc_bins=`command ls $GLOBAL_BIN_PATH/* | sed -E 's/.*\///' | tr '\n' ' '`

  echo "$_all_gc_bins"
}


# Add $path/global/bin to PATH in .rc shell file


# automatically run git_ssh if the environment variable is set
if [ -n "$GIT_SSH_DEFAULT_CHOICE" ]; then
  echo "$_GLOBAL_SHELL_LEFT GIT_SSH_DEFAULT_CHOICE is set, running git_ssh"
  git_ssh
fi

echo "$_GLOBAL_SHELL_LEFT GLOBAL SHELL INITIALIZED" && echo ""

#export HISTFILE="$HOME/.global/shell_history"




if [ -f "./shell.sh" ]; then
    . ./shell.sh;
fi







