

history() {
    if [ -z "$GLOBAL_SHELL_HISTORY" ]; then
        echo "GLOBAL_SHELL_HISTORY is not set, using default"
        command history "$@"
    else
        python3 "$HOME/global/cron/ghistory.py" print
    fi
}