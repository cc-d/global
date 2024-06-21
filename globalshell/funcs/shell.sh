

history() {
    _gs_cutom_hist=1
    if which python3 &>/dev/null; then
        _gs_hist_pycmd="python3"
    else
        _gs_hist_pycmd="python"
    fi

    if [ "$1" = "-o" ] || [ "$1" = "--original" ]; then
        echo "Using original history command"
        shift
        builtin history $@
    elif [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
        echo "Usage: history [-o|--original] [args]"
        echo "    -o|--original: Use the original history command"
        return 0
    elif [ -z "$GLOBAL_SHELL_HISTORY" ]; then
        echo "GLOBAL_SHELL_HISTORY is not set, using default history cmd"
        builtin history $@
    else
        $_gs_hist_pycmd "$HOME/global/scripts/ghistory.py" $@
    fi

}

