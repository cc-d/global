#!/usr/bin/env bash

evar() {
    # Check if the arguments are passed in the format $NAME=$VALUE
    if [[ "$#" -eq 1 ]] && [[ "$1" =~ ^[^=]+=.+$ ]]; then
        # Split the input into name and value
        name="${1%%=*}"
        value="${1#*=}"
    else
        # Get the name and value of the environment variable
        name="$1"
        value="$2"
    fi

    # Escape special characters in the value
    escaped_value=$(printf "%q" "$value")

    # Determine the path to the rc file based on the OS
    if [ "$(uname)" = "Darwin" ]; then
        # Use .zshrc on macOS
        rc_file="$HOME/.zshrc"
    else
        # Use .bashrc on Linux
        rc_file="$HOME/.bashrc"
    fi

    # Check if the export line already exists in the rc file
    if grep -q "$name=['\"]\{0,1\}.*['\"]\{0,1\}" "$rc_file"; then
        # If it does, update the line
        echo "evar exists in rc updating"
        sed -i -e "s|^.*$name=['\"]\{0,1\}.*['\"]\{0,1\}|export $name=$escaped_value|" "$rc_file"
    else
        # If it doesn't, add the line
        echo "evar $name=$value does not exist adding now"
        echo "export $name=$escaped_value" >> "$rc_file"
    fi

    # Run the export line in the shell
    echo "export $name=$escaped_value"
    export "$name=$escaped_value"
}


update_gpath() {
    script_dir="$HOME/global/syms"
    export PATH="$PATH:$script_dir"

    if [ -n "$BASH" ]; then
        shellrc="$HOME/.bashrc"
    elif [ -n "$ZSH_NAME" ]; then
        shellrc="$HOME/.zshrc"
    else
        echo "Unsupported shell. Please manually update your shell's rc file."
        return 1
    fi

    if ! grep -q "$script_dir" "$shellrc"; then
        echo "export PATH=\"\$PATH:$script_dir\"" >> "$shellrc"
        echo "Added $script_dir to the PATH in $shellrc"
    else
        echo "$script_dir is already in the PATH in $shellrc"
    fi
}

