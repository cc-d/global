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
    # Validate input
    if [ "$#" -eq 0 ]; then
        echo "evar: missing arguments"
        return 1
    fi

    # Check if the arguments are passed in the format $NAME=$VALUE
    if [ "$#" -eq 1 ] && echo "$1" | grep -qE '^[^=]+=.+'; then
        # Split the input into name and value
        name="${1%%=*}"
        value="${1#*=}"
    elif [ "$#" -eq 2 ]; then
        # Get the name and value of the environment variable
        name="$1"
        value="$2"
    else
        echo "evar: invalid number of arguments"
        return 1
    fi

    # Escape special characters in the value
    escaped_value=$(printf "%s" "$value")

    # Determine the path to the rc file based on the shell
    rc_file="$HOME/.bashrc"
    [ "$(basename "$SHELL")" = "zsh" ] && rc_file="$HOME/.zshrc"

    # Check if the export line already exists in the rc file
    if grep -qE "^export $name=" "$rc_file"; then
        # If it does, update the line
        sed -i.bak "s|^export $name=.*|export $name=$escaped_value|" "$rc_file"
        echo "evar exists in rc, updating"
    else
        # If it doesn't, add the line
        echo "export $name=$escaped_value" >> "$rc_file"
        echo "evar $name=$value does not exist, adding now"
    fi

    # Run the export line in the current shell
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
        # note: it isnt killed afterwards
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
  git pullt

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

actvenv() {
  venvfile=$(find . -name 'activate' | head -n 1 | sed -E 's/^\.\//. /')
  if [ -z "$venvfile" ]; then
    echo "No virtualenv found."
    return 1
  else
    eval "$venvfile"
  fi
}


gitconf() {
    NAME="Cary Carter"
    EMAIL="$2"

    echo $1

    if [ -z "$EMAIL" ]
    then
        echo "Please provide an email address"
        exit 1
    fi

    if [ "$1" = "global" ]
    then
        git config --global user.name "$NAME"
        git config --global user.email "$EMAIL"
        echo "Global git config updated with name/email: $NAME $EMAIL"
    elif [ "$1" = "local" ]
    then
        git config --local user.name "$NAME"
        git config user.email "$EMAIL"
        echo "Local git config updated with name/email: $NAME $EMAIL"
    elif [ "$1" = "system" ]
    then
        git config --system user.name "$NAME"
        git config --system user.email "$EMAIL"
        echo "System git config updated with name/email: $NAME $EMAIL"
    else
        echo "Invalid option: use 'global', 'local', or 'system'"
    fi
}


gitnewbranch() {
  echo "Branch to branch off from [default: master]: "; read base_branch
  : "${base_branch:=master}"

  echo "Stash local changes? [y/n]"; read stash_choice
  [ "$stash_choice" = "y" ] && git stash || {
    git reset --hard HEAD; git clean -fd;
  }

  git checkout "$base_branch" && git pull origin "$base_branch" || {
    echo "Error: Couldn't update base branch."; return 1;
  }
  [ "$stash_choice" = "y" ] && git stash apply

  echo "New branch name (or paste 'git checkout -b <name>'):"; read new_branch_input
  new_branch=$(echo "$new_branch_input" | awk '/git checkout -b/ {print $4}')
   : "${new_branch:=$new_branch_input}"

  git checkout -b "$new_branch" && git push -u origin "$new_branch" || {
    echo "Error: Couldn't create and push new branch.";
    return 1;
  }

  echo "New branch created and pushed: $new_branch"
}


# Detects the current Operating System and Architecture
ostype() {
  os_type="unknown"
  arch_type="unknown"

  case "$(uname -s)" in
    Darwin)
      os_type="macos"
      ;;
    Linux)
      os_type="linux"
      ;;
    FreeBSD)
      os_type="freebsd"
      ;;
    NetBSD)
      os_type="netbsd"
      ;;
    OpenBSD)
      os_type="openbsd"
      ;;
    SunOS)
      os_type="solaris"
      ;;
    AIX)
      os_type="aix"
      ;;
    *)
      os_type="unknown"
      ;;
  esac

  case "$(uname -m)" in
    x86_64)
      arch_type="x86_64"
      ;;
    i386|i486|i586|i686)
      arch_type="x86"
      ;;
    armv6*)
      arch_type="armv6"
      ;;
    armv7*)
      arch_type="armv7"
      ;;
    arm64|aarch64)
      arch_type="arm64"
      ;;
    s390x)
      arch_type="ibm_s390"
      ;;
    ppc64le)
      arch_type="powerpc64le"
      ;;
    *)
      arch_type="unknown"
      ;;
  esac

  echo "$os_type $arch_type"
}

echo_gptfile() {
  title="<<! FILE: $1 !>>"
  if [ ! -f "$1" ]; then
    return 1
  fi
  content=$(cat "$1")
  content=$(echo "$content" | sed '/^$/d')

  if [ -z "$content" ]; then
    output="$output$title"
  else
    output="$output$title\`\`\`$content\`\`\`"
  fi
}

gptfiles() {
  output=""
  os_arch=$(ostype)
  os_type=$(echo "$os_arch" | awk '{print $1}')

  for f in "$@"; do
    for rf in $(rec_sh "$f"); do
      echo_gptfile "$rf"
    done
  done

  case "$os_type" in
    "macos")
      echo -e "$output" | pbcopy
      ;;
    "linux")
      echo -e "$output" | xclip -selection clipboard
      ;;
    "unknown")
      echo "Unsupported OS. Cannot copy to clipboard."
      ;;
  esac

  echo -e "$output"
  echo "Copied to clipboard"
  echo ''
}


gitacpush() {
  # Add all changes to the staging area
  git add -A

  # Generate a commit message
  commit_message=$(git status --porcelain | awk '{print $2}' | tr '\n' ' ')

  # Truncate commit message if it's too long
  max_len=50
  if [ "${#commit_message}" -gt "$max_len" ]; then
    commit_message="${commit_message:0:$max_len}..."
  fi

  # If there's nothing to commit, exit
  if [ -z "$commit_message" ]; then
    echo "Nothing to commit."
    return 1
  fi

  # Commit the changes
  git commit -m "$commit_message"

  # Push to the remote repository
  git push

  echo "Successfully committed and pushed: $commit_message"
}

gitdatecommit() {
  # gitdatecommit -m "Your commit message" -d "10-03-2023" -t "01:01:30"
  _gd_commit_message="no commit message provided"
  _gd_date_input=$(date '+%d-%m-%Y')
  _gd_time_input=$(date '+%H:%M:%S')
  while [ $# -gt 0 ]; do
    case "$1" in
      -m)
        shift
        _gd_commit_message="$1"
        ;;
      -d)
        shift
        _gd_date_input="$1"
        ;;
      -t)
        shift
        _gd_time_input="$1"
        ;;
      *)
        echo "Invalid option: $1" >&2
        return 1
        ;;
    esac
    shift
  done
  _gd_day=$(echo "$_gd_date_input" | cut -d- -f1)
  _gd_month=$(echo "$_gd_date_input" | cut -d- -f2)
  _gd_year=$(echo "$_gd_date_input" | cut -d- -f3)

  _gd_git_date="${_gd_year}-${_gd_month}-${_gd_day}T${_gd_time_input}"

  GIT_AUTHOR_DATE="$_gd_git_date" GIT_COMMITTER_DATE="$_gd_git_date" git commit -m "$_gd_commit_message"
}


posix_ranstr() {
    _prs_length=${1:-8}
    _prs_charset=${2:-'a-zA-Z0-9'}
    LC_ALL=C tr -dc "$_prs_charset" < /dev/urandom | head -c "$_prs_length"
    echo
}

screenproc() {
    _SCREENPROC_FILE="$HOME/.screenproc"
    _sp_generate_session_name() {
        echo "sproc$(date '+%H%S')`posix_ranstr 3 'a-z'`";
    }

    _sp_list_sessions() {
        grep -F -f "$_SCREENPROC_FILE" <(screen -ls) || echo "No active screenproc sessions.";
    }

    _sp_kill_session() {
        if grep -q "$1" "$_SCREENPROC_FILE"; then
            screen -S "$1" -X quit
            grep -v "$1" "$_SCREENPROC_FILE" > "$_SCREENPROC_FILE.tmp" && \
                mv "$_SCREENPROC_FILE.tmp" "$_SCREENPROC_FILE"
        else echo "Session $1 not found.";
        fi
    }

    _sp_kill_all_sessions() {
        while read -r session; do
            screen -S "$session" -X quit;
        done < "$_SCREENPROC_FILE";
        rm -f "$_SCREENPROC_FILE";
    }

    [ ! -f "$_SCREENPROC_FILE" ] && touch "$_SCREENPROC_FILE"

    case $1 in
        -list)_sp_list_sessions;;
        -kill)_sp_kill_session "$2";;
        -killall)_sp_kill_all_sessions;;
        -h | -help | "")
            echo "Usage: screenproc [OPTION]... [COMMAND]..."
            echo "    -list             List all screenproc sessions."
            echo "    -kill NAME    Kill a specific screenproc session."
            echo "    -killall        Kill all screenproc sessions."
            echo "    COMMAND         Execute COMMAND in a new screen session."
            ;;
        *)
            session_name=$(_generate_session_name)
            echo "$session_name" >> "$_SCREENPROC_FILE"
            echo "$session_name"
            screen -dmS "$session_name" sh -c "$*"
            ;;
    esac
}



pasterun() {
  # Check if the type of the program is provided
  if [ -z "$1" ]; then
    echo "Usage: pasterun command (then paste src code)"
    return 1
  fi

  # Notify the user to paste the program
  echo "Paste your program and press Ctrl-D when done:"
  tmpfile=$(mktemp /tmp/pasted_program.XXXXXX)
  cat > "$tmpfile"
  eval "$1 $tmpfile"
}