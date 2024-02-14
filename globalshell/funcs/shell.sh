#!/bin/sh

history() {
    if [ -z "$GLOBAL_SHELL_HISTORY" ]; then
        command history "$@"
    else
        if [ -f "$HOME/.zsh_history" ]; then
            cat "$HOME/.zsh_history" | uniq
        elif [ -f "$HOME/.bash_history" ]; then
            cat "$HOME/.bash_history" | uniq
        else
            echo "No history file found"
        fi
    fi
}
