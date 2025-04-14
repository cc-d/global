# changes all files provided or in current dir to 755 and current user:group

fixperms() {
    _fp_curuser=$(whoami)
    _fp_curgroup=$(id -g -n)
    if [ -z "$1" ]; then
        _fp_files=""
        _fp_fcount=0
        for f in `ls -Am --color=never`; do
            if echo "$f" | grep -q -E '(^\.\/?,$|^\.\.\/?,$)'; then
                echo "Skipping $f"
                continue
            fi

            _fp_file=$(echo "$f" | sed 's/,$//')
            _fp_fcount=$(( _fp_fcount + 1 ))
            echo "Changing perms for file: $_fp_file"
        done
        echo "No files specified, use all files in current directory? (y/n)"
        read -r _fp_confirm
        if [ "$_fp_confirm" = "y" ]; then
            echo "Fixing permission for $_fp_fcount files"
            _fp_files="."
        else
            echo "No files specified, exiting"
            return 1
        fi
    else
        _fp_files="$@"
    fi
    echo "Fixing permission for files: $_fp_files"
    echo "Changing owner to $_fp_curuser:$_fp_curgroup"
    echo "Changing permissions to 755"
    sudo chown -R $_fp_curuser:$_fp_curgroup $_fp_files
    sudo chmod -R 755 $_fp_files
}

