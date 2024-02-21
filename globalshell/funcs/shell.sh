#!/bin/sh

history() {
    if [ -z "$GLOBAL_SHELL_HISTORY" ]; then
        echo "GLOBAL_SHELL_HISTORY is not set, using default"
        command history "$@"
    else
        if [ -f "$HOME/.zsh_history" ]; then
            _GC_HISTORY_FILE="$HOME/.zsh_history"
        elif [ -f "$HOME/.bash_history" ]; then
            _GC_HISTORY_FILE="$HOME/.bash_history"
        else
            echo "No history file found"
            return 1
        fi
    fi

    awk '{$1=$1}; !x[$0]++' "$_GC_HISTORY_FILE" | nl -w 1 -s " " -ba
}