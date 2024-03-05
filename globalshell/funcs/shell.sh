

history() {
    if [ -z "$GLOBAL_SHELL_HISTORY" ]; then
        echo "GLOBAL_SHELL_HISTORY is not set, using default"
        command history "$@"
    else
        python3 "$HOME/global/cron/gc_history.py"
        _GC_HISTORY_FILE="$HOME/.global/shell_history"
        for _GC_HIST_LINE in \
            `awk '{$1=$1}; !x[$0]++' "$_GC_HISTORY_FILE" | nl -w 1 -s " " -ba`;
        do
            echo "$_GC_HIST_LINE"
        done
    fi
}