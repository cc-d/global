#!/bin/sh


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

safesource () {
  if command -v source &>/dev/null; then
    source "$f"
  else
    . "$f"
  fi
}

substr_in () {
  case "$2" in
    *$1*) return 0;;
    *) return 1;;
  esac
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
       screen -list || grep -F -f "$_SCREENPROC_FILE" || echo "No active screenproc sessions.";
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



dirfiles() {
    _df_dir="$1"


    # Print the directory name
    if [ ! -z "$2" ]; then
        echo "|${2:1}$(basename $_df_dir)/"
    else
        echo ''
        if [ "$1" = "." ]; then
            echo "$(basename `pwd`)/"
        elif [ "$1" = ".." ]; then
            echo "$(dirname `pwd`)/"
        else
            echo "$(basename $_df_dir)/"
        fi
    fi

    # List files in the current directory
    curfiles=""
    for df_f in $(find "$_df_dir" -maxdepth 1 -mindepth 1 -type f \
    -not -name '*.pyc' | sort -bh); do
        curfiles="$curfiles `basename $df_f`"
    done

    if [ ! -z "$curfiles" ]; then
        if [ ! -z "$2" ]; then
            echo "|${2:0}$curfiles"
        else
            echo "|$curfiles"
        fi
    fi

    # Recursively list files in subdirectories
    for df_d in $(find "$_df_dir" -maxdepth 1 -mindepth 1 -type d \
    -not -name '__pycache__' -not -name 'venv' -not -name '.git' \
    -not -path '*node_modules*' -not -name '.pytest_cache' \
    -not -path '*/_cacache/*' | sort -bh); do
        dirfiles $df_d "$2  "
    done
}


tstime() {
  _tstime1=`timestamp`
  eval "$@"
  _tstime2=`timestamp`
  _tstime_diff=$(echo "$_tstime2 $_tstime1" | awk '{print $1 - $2}')
  echo "time: $_tstime_diff ms"
}


columnate() {
  ncols=${1:-4}
  colw=${2:-$(($(tput cols) / ncols - 1))}
  colw=$((colw > 4 ? colw : 4))
  i=0
  printed=()
  while read -r line; do
    if [ ${#line} -gt $((colw - 2)) ]; then
      shortline="${line:0:$((colw - 2))}.."
    else
      shortline="$line"
    fi
    found=0
    for p in "${printed[@]}"; do
      if [ "$p" = "$shortline" ]; then
        found=1
        break
      fi
    done
    if [ $found -eq 0 ]; then
      printf "%-${colw}s " "$shortline"
      printed+=("$shortline")
      i=$((i + 1))
      [ $((i % ncols)) -eq 0 ] && { printf "\n"; i=0; }
    fi
  done
  [ $((i % ncols)) -ne 0 ] && printf "\n"
}


get_shell_rc_file() {
  case "$(basename "$SHELL")" in
    "bash")
        [ -f "$HOME/.bash_profile" ] && echo "$HOME/.bash_profile" \
            || [ -f "$HOME/.bash_login" ] && echo "$HOME/.bash_login" \
            || echo "$HOME/.profile" ;;
    "zsh")
        [ -f "$HOME/.zshrc" ] && echo "$HOME/.zshrc" \
        || [ -f "$HOME/.zshenv" ] && echo "$HOME/.zshenv" \
        || [ -f "$HOME/.zprofile" ] && echo "$HOME/.zprofile" \
        || echo "$HOME/.zlogin" ;;
    "fish")
        echo "$HOME/.config/fish/config.fish" ;;
    *) echo "$HOME/.profile" ;;
  esac
}


sourceshell() {
  _SSPADSTR="!!!!!!!!!!!!!"
  _SSRCFILE=$(get_shell_rc_file | head -n 1)
  if [ -z "$_SSRCFILE" ]; then
    echo "$_SSPADSTR Could not find shell rc file $_SSPADSTR"
    return 1
  fi
  if command -v source &>/dev/null; then
  echo "$_SSPADSTR sourcing (using source) $_SSRCFILE $_SSPADSTR"
    source "$_SSRCFILE"
  else
    echo "$_SSPADSTR sourcing (using .) $_SSRCFILE $_SSPADSTR"
    . "$_SSRCFILE"
  fi

}
