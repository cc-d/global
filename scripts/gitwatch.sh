#!/bin/sh

# Print usage information
usage() {
    echo ""
    echo "Usage: $0 [options] <path_to_git_repo> [interval_in_seconds]"
    echo "Options: \n"
    echo "  -h, --help           Show this help message"
    echo "  -n, --no-pull            Run pre-pull and post-pull actions without pulling"
    echo ""
}

# Initialize variables
_NO_PULL=0
_REPO_PATH=""
_INTERVAL=""

# Parse command line arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help|help)
            usage
            exit 0
            ;;
        -n|--no-pull)
            _NO_PULL=1
            shift
            ;;
        *)
            if [ -d "$1" ]; then
                _REPO_PATH="$1"
                shift
            elif echo "$1" | grep -q '^[0-9]+$'; then
                _INTERVAL="$1"
                shift
            else
                echo "Error: Invalid argument $1"
                usage
                exit 1
            fi
            ;;
    esac
done

# Set default repository path to the script's directory if not provided
if [ -z "$_REPO_PATH" ]; then
    _REPO_PATH="$(cd "$(dirname "$0")" && pwd)"
fi

REPO_NAME=$(basename "$_REPO_PATH")
PROCESS_NAME="GitWatch_$REPO_NAME"

# Ensure repository path is provided
if [ -z "$_REPO_PATH" ]; then
    echo "Error: Repository path is required."
    usage
    exit 1
fi

# Function to handle termination of existing screen sessions
kill_existing_session() {
    if screen -ls | grep -q "$PROCESS_NAME"; then
        echo "An existing process was found for $PROCESS_NAME. Killing..."
        screen -S "$PROCESS_NAME" -X quit
        echo "Process killed."
    fi
}

# Define default pre-pull and post-pull actions
pre_pull_action() {
    echo "Pre-pull action executed."
}

post_pull_action() {
    echo "Post-pull action executed."
}

# Function to execute Git operations
git_operations() {
    cd "$_REPO_PATH" || exit 1
    git fetch
    LOCAL_COMMIT=$(git rev-parse HEAD)
    REMOTE_COMMIT=$(git rev-parse "@{u}")

    if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
        pre_pull_action || return 1
        if [ -z "$_NO_PULL" ]; then
            echo "Changes detected. Pulling changes..."
            git pull --quiet || return 1
        else
            echo "Pulling changes skipped."
        fi
        post_pull_action || return 1
        echo "Operations completed."
    else
        echo "No changes detected."
    fi
}

# Check and manage screen session for interval-based execution
if [ -n "$_INTERVAL" ]; then
    kill_existing_session
    # Start the script in a new screen session with necessary environment variables
    screen -dmS "$PROCESS_NAME" \
        env GITWATCH_REPO_PATH="$_REPO_PATH" GITWATCH_INTERVAL="$_INTERVAL" \
        sh -c "$0 --no-pull \"$_REPO_PATH\" \"$_INTERVAL\""
    echo "Spawned a new background screen session named $PROCESS_NAME"
    exit 0
fi

# Execute Git operations directly if no interval is provided
git_operations
