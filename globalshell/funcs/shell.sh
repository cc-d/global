#!/bin/sh

history() {
    if [ -n "$GLOBAL_SHELL_HISTORY" ]; then
        if [ ! -d ~/.global ]; then
            mkdir -p ~/.global
        fi
        if [ ! -f ~/.global/shell_history ]; then
            touch ~/.global/shell_history
        fi
        for HISTFILE in "$HOME/.bash_history" "$HOME/.zsh_history"; do
            if [ -f "$HISTFILE" ]; then
                cat "$HISTFILE" >> "$HOME/.global/shell_history"
            fi


        done
        if [ -f "$HOME/.global/shell_history" ]; then
            cat "$HOME/.global/shell_history" | uniq > "$HOME/.global/shell_history.tmp"
            mv "$HOME/.global/shell_history.tmp" "$HOME/.global/shell_history"
        fi
        cat "$HOME/.global/shell_history"

    else
        command history "$@"
    fi
}

