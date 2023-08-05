#!/bin/sh

get_shell_rc_file() {
  case "$(basename "$SHELL")" in
    "bash")
        [ -f "$HOME/.bash_profile" ] && echo "$HOME/.bash_profile" \
            || [ -f "$HOME/.bash_login" ] && echo "$HOME/.bash_login" \
            || echo "$HOME/.profile" ;;
    "zsh")
        [ -f "$HOME/.zshenv" ] && echo "$HOME/.zshenv" \
        || [ -f "$HOME/.zprofile" ] && echo "$HOME/.zprofile" \
        || [ -f "$HOME/.zshrc" ] && echo "$HOME/.zshrc" \
        || echo "$HOME/.zlogin" ;;
    "fish")
        echo "$HOME/.config/fish/config.fish" ;;
    *) echo "$HOME/.profile" ;;
  esac
}


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
    if [ $(basename $SHELL) == "zsh" ]; then
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

    # Check if environment variable is set and is valid
    if [ -n "$GIT_SSH_DEFAULT_CHOICE" ] && [ "$GIT_SSH_DEFAULT_CHOICE" -ge 1 ] && [ "$GIT_SSH_DEFAULT_CHOICE" -le "$#" ]; then
        choice=$GIT_SSH_DEFAULT_CHOICE
        echo "Using GIT_SSH_DEFAULT_CHOICE: $choice"
    else
        # prompt user on the same line for which file to use with ssh-add
        echo -n "Select which SSH keyfile to use with ssh-add: "
        read choice
    fi

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


# intentionally extremely simple func to just return
# $test as a given $color for its foreground color

colortext () {
    text="$1"
    color_name="$2"
    reset="$(tput sgr0)"

    case "$color_name" in
        black) color_code="$(tput setaf 0)" ;;
        red) color_code="$(tput setaf 1)" ;;
        green) color_code="$(tput setaf 2)" ;;
        yellow) color_code="$(tput setaf 3)" ;;
        blue) color_code="$(tput setaf 4)" ;;
        magenta) color_code="$(tput setaf 5)" ;;
        cyan) color_code="$(tput setaf 6)" ;;
        white) color_code="$(tput setaf 7)" ;;
        *) color_code="" ;;
    esac

    echo "${color_code}${text}${reset}"
}


gptfiles() {
  for path in "$@"; do
    if [ -d "$path" ]; then
      for file in $(find "$path" -maxdepth 1 -type f); do
        echo -e "\nFile: $file"
        if [ -s "$file" ]; then
          echo "\`\`\`"
          cat "$file"
          echo -e "\n\`\`\`"
        fi
      done
    elif [ -f "$path" ]; then
      echo -e "\nFile: $path"
      if [ -s "$path" ]; then
        echo "\`\`\`"
        cat "$path"
        echo -e "\n\`\`\`"
      fi
    else
      echo "$path is not a valid directory or file path."
    fi
  done
}
