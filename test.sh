#!/bin/sh

list_dir() {
    dir="$1"
    indent="$2"
    for entry in "$dir"/*; do
        [ -e "$entry" ] || continue
        entry_name=$(basename "$entry")
        printf "%s%s\n" "$indent" "$entry_name"
        if [ -d "$entry" ]; then
            (
                cd "$entry" || exit 1
                list_dir "." "$indent  "
                cd ..
            )
        fi
    done
}

root_dir="."

printf "%s\n" "$root_dir"  # Print the current directory
list_dir "$root_dir" "  "  # Start with 2 spaces of initial indentation

