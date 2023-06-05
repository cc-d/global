#!/usr/bin/env bash

evar() {
    # Check if the arguments are passed in the format $NAME=$VALUE
    if [ "$#" -eq 1 ] && echo "$1" | grep -qE '^[^=]+=.+'; then
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


# lists all private .ssh keyfiles in ~/.ssh if no filepath is provided
git-ssh() {
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

    # 1-index user choices
    index=1
    set -- $(echo -e $sshkeys)
    echo ''
    for kpath; do
        echo "[$index] $kpath";
        index=$((index + 1));
    done
    echo ''

    # prompt user on the same line for which file to use with ssh-add
    echo -n "Select which SSH keyfile to use with ssh-add: "
    read choice

    if [ "$choice" -ge 1 ] && [ "$choice" -le "$#" ]; then
        # start ssh-agent for this shell
        eval "$(ssh-agent -s)"

        # clever
        cpath=$(eval "echo \$$(echo $choice)")
        ssh-add $cpath
    else
        echo "ERROR: $choice is not a valid choice."
    fi
}


# Reverts all merge commits up to a specific commit
revert-to-commit() {
  # Check that a commit hash was provided
  if [ $# -eq 0 ]
  then
    echo "No commit hash provided. Usage: revert_to_commit <commit_hash>"
    return 1
  fi

  target_commit="$1"
  commit_count=0

  echo "Checking out and pulling master"
  git checkout master
  git pull

  branch_name="revert-master-$(date +%s)"
  echo "Creating new branch: $branch_name"
  git checkout -b "$branch_name"

  echo "Reverting to commit: $target_commit"

  # Iterate over all merge commits
  for commit in $(git log --merges --pretty=format:"%H")
  do
    # If we've reached the target commit, stop reverting
    if [ "$commit" = "$target_commit" ]
    then
      break
    fi

    # Revert the current commit
    git revert -m 1 "$commit"
    commit_count=$((commit_count+1))
  done

  # Echo the result of the operation
  echo "Reverted $commit_count commits."
  echo "Please push the branch with the following command:"
  echo "git push origin $branch_name"
}
