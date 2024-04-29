#!/bin/sh

# Define functions for pre-pull and post-pull actions
pre_pull_action() {
    echo "Pre-pull action executed."
}

post_pull_action() {
    echo "Post-pull action executed."
}



# Print usage information
usage() {
    echo ""
    echo "Usage: $0 [options] [path_to_git_repo] [interval_in_seconds]"
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -n, --no-pull        Run pre-pull and post-pull actions without pulling"
    echo "  -f, --force-actions Run pre-pull and post-pull actions even if no changes detected"
    echo ""
}

# Initialize variables
GITWATCH_NO_PULL=0
GITWATCH_REPO_PATH=""
GITWATCH_INTERVAL=""
GITWATCH_FORCE_ACTIONS=0

# Parse command line arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help|help)
            usage
            exit 0
            ;;
        -n|--no-pull)
            GITWATCH_NO_PULL=1
            shift
            ;;
        -f|--force-actions)
            GITWATCH_FORCE_ACTIONS=1
            shift
            ;;
        *)
            if [ -d "$1" ] && [ -z "$GITWATCH_REPO_PATH" ]; then
                GITWATCH_REPO_PATH="$1"
                shift
            elif echo "$1" | grep -qE '^[0-9]+$' && [ -z "$GITWATCH_INTERVAL" ]; then
                GITWATCH_INTERVAL="$1"
                shift
            else
                echo "Error: Invalid argument $1"
                usage
                exit 1
            fi
            ;;
    esac
done

# Set default repository path if not provided
if [ -z "$GITWATCH_REPO_PATH" ]; then
    GITWATCH_REPO_PATH=$(pwd)
    while [ "$GITWATCH_REPO_PATH" != "/" ] && [ ! -d "$GITWATCH_REPO_PATH/.git" ]; do
        GITWATCH_REPO_PATH=$(dirname "$GITWATCH_REPO_PATH")
    done
    if [ ! -d "$GITWATCH_REPO_PATH/.git" ]; then
        echo "Error: No .git directory found in any parent directory."
        exit 1
    fi
fi

REPO_NAME=$(basename "$GITWATCH_REPO_PATH")
PROCESS_NAME="GitWatch_$REPO_NAME"

# Kill existing instances of the GitWatch screen session
kill_existing_sessions() {
    # Wipe out dead screen sessions first
    screen -wipe

    # Now fetch all existing session IDs and names, filter for our process, and terminate them
    screen -ls | grep "$PROCESS_NAME" | awk '{print $1}' | while IFS= read -r session_info
    do
        session_id=$(echo "$session_info" | awk -F '.' '{print $1}')
        echo "Terminating existing GitWatch session: $session_id"
        screen -S "$session_id" -X quit
    done
}


pre_post_pull() {
    echo "Running pre-pull action..."
    pre_pull_action
    if [ "$GITWATCH_NO_PULL"="1" ]; then
        echo "Changes detected. Pulling changes..."
        git pull
        echo "Changes pulled successfully."
    else
        echo "GITWATCH_NO_PULL=" "$GITWATCH_NO_PULL"
        echo "Pulling changes skipped."
    fi
    post_pull_action
}


# Function to execute Git operations
git_operations() {
    cd "$GITWATCH_REPO_PATH" || exit 1

    while true; do
        git fetch
        BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

        LOCAL_COMMIT=$(git rev-parse --short HEAD)
        REMOTE_COMMIT=$(git rev-parse --short origin/$BRANCH_NAME)

        # ensure same length as --short
        REMOTE_COMMIT=${REMOTE_COMMIT:0:7}
        echo "Local commit: $LOCAL_COMMIT | Remote commit: $REMOTE_COMMIT | Branch: $BRANCH_NAME"

        if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
            echo "Changes detected. Running pre-pull and post-pull actions..."
            pre_post_pull
        elif [ "$GITWATCH_FORCE_ACTIONS" -eq 1 ]; then
            echo "No changes detected but force actions flag is set."
            echo "Force Running pre-pull and post-pull actions..."
            pre_post_pull
            exit 0
        else
            echo "No changes detected. $LOCAL_COMMIT is up to date with $REMOTE_COMMIT."
        fi

        if [ -n "$GITWATCH_REPEAT" ]; then
            echo "sleeping for $GITWATCH_INTERVAL seconds..."
            sleep "$GITWATCH_INTERVAL"
        else
            echo "Exiting..."
            exit 0
        fi
    done

}

# Manage screen session
if [ -n "$GITWATCH_INTERVAL" ] && [ -z "$GITWATCH_REPEAT" ]; then
    kill_existing_sessions

    if [ -n "$GITWATCH_NO_PULL" ]; then
        ARG_NO_PULL="--no-pull"
    else
        ARG_NO_PULL=""
    fi

    echo "Running Command: "
    echo "screen -dmS $PROCESS_NAME sh -c 'GITWATCH_REPEAT=1 $0 $GITWATCH_REPO_PATH $GITWATCH_INTERVAL $ARG_NO_PULL'"

    screen -dmS "$PROCESS_NAME" \
        sh -c "GITWATCH_REPEAT=1 $0 $GITWATCH_REPO_PATH $GITWATCH_INTERVAL $ARG_NO_PULL"

    echo "Spawned a new background screen session named $PROCESS_NAME"
    exit 0
else
    git_operations
    exit 0
fi
