#!/bin/sh

# lists all private .ssh keyfiles in ~/.ssh if no filepath is provided
# if GIT_SSH_DEFAULT_CHOICE is set, it will use that keyfile automatically
# it is suggested to use this function in your shell startup script if
# it is not password protected

git_ssh() {
    # this appears on the left of all shell messages

    # we'll use a multi-line string like a pseudo-array for this
    sshkeys=""
    if [ -d "$HOME/.ssh" ]; then
        # find every openssh private key file in .ssh
        for f in $(find ~/.ssh -type f); do
            if [ "$(head -n 1 $f)" = '-----BEGIN OPENSSH PRIVATE KEY-----' ]; then
                sshkeys="$sshkeys$(echo $f)\n"
            fi
        done
    fi

    index=1
    set -- $(printf "%b" "$sshkeys")
    echo ''
    for kpath; do
        echo "[$index] $kpath";
        index=$((index + 1));
    done
    echo ''

    # Check if environment variable is set and is valid
    if [ -n "$GIT_SSH_DEFAULT_CHOICE" ] && [ "$GIT_SSH_DEFAULT_CHOICE" -ge 1 ] && [ "$GIT_SSH_DEFAULT_CHOICE" -le "$#" ]; then
        choice=$GIT_SSH_DEFAULT_CHOICE
        echo "$_GLOBAL_SHELL_LEFT Using GIT_SSH_DEFAULT_CHOICE: $choice"
    else
        # prompt user on the same line for which file to use with ssh-add
        echo -n "$_GLOBAL_SHELL_LEFT Select which SSH keyfile to use with ssh-add: "
        read choice
    fi

    if [ "$choice" -ge 1 ] && [ "$choice" -le "$#" ]; then
        # start ssh-agent for this shell
        # note: it isnt killed afterwards
        if [ -z "$SSH_AUTH_SOCK" ]; then
            eval "$(ssh-agent -s)"
            # Ensure the ssh-agent is killed when the shell is closed
            trap 'test -n "$SSH_AGENT_PID" && eval `ssh-agent -k`' EXIT
        fi

        # clever
        cpath=$(eval "echo \$$(echo $choice)")
        if ! ssh-add $cpath 2>/dev/null; then
            echo "$_GLOBAL_SHELL_LEFT: Failed to add SSH key. Retrying..."
            eval "$(ssh-agent -s)"
            ssh-add $cpath || echo "$_GLOBAL_SHELL_LEFTERROR: Failed to add SSH key."
        fi
    else
        echo "$_GLOBAL_SHELL_LEFT: $choice is not a valid choice."
    fi
}



