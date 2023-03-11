#!/bin/bash

# Get the name and value of the environment variable
name="$1"
value="$2"

# Determine the path to the rc file based on the OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Use .zshrc on macOS
    rc_file="$HOME/.zshrc"
else
    # Use .bashrc on Linux
    rc_file="$HOME/.bashrc"
fi

# Check if the export line already exists in the rc file
if grep -q "export $name=['\"]\{0,1\}$value['\"]\{0,1\}" "$rc_file"; then
    # If it does, update the line
    echo "evar exists in rc updating"
    sed -i.bak "s/export $name=['\"]\{0,1\}.*['\"]\{0,1\}/export $name=$value/" "$rc_file"
else
    # If it doesn't, add the line
    echo "evar $name=$value does not exist adding now"
    echo "export $name=$value" >> "$rc_file"
fi

# Run the export line in the shell
echo "export $name=$value"
export "$name=$value"
