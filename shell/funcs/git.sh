#!/bin/sh

# Reverts all merge commits up to a specific commit
revert_to_commit() {
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


gitconf() {
    _CONFNAME="Cary Carter"
    if [ ! -z "$(echo "$1" | grep '@')" ]; then
        _CONFEMAIL="$1"
        _CONFSCOPE=$(echo "$2" | sed 's/-//g')
    else
        _CONFEMAIL="$2"
        _CONFSCOPE=$(echo "$1" | sed 's/-//g')
    fi
    if [ -z "$_CONFEMAIL" ]; then
        echo "Please provide an email address"
        return
    elif [ -z "$_CONFSCOPE" ]; then
        echo "Please provide a scope: 'global', 'local', or 'system'"
        return
    fi
    if [ "$_CONFSCOPE" = "global" ]; then
        git config --global user.name "$_CONFNAME"
        git config --global user.email "$_CONFEMAIL"
        echo "Global git config updated with name/email: $_CONFNAME $_CONFEMAIL"
    elif [ "$_CONFSCOPE" = "local" ]; then
        git config --local user.name "$_CONFNAME"
        git config user.email "$_CONFEMAIL"
        echo "Local git config updated with name/email: $_CONFNAME $_CONFEMAIL"
    elif [ "$_CONFSCOPE" = "system" ]; then
        git config --system user.name "$_CONFNAME"
        git config --system user.email "$_CONFEMAIL"
        echo "System git config updated with name/email: $_CONFNAME $_CONFEMAIL"
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



gitacpush() {

  git status -u
  echo "Continue (y/n)?"
  read _gac_count

  if [ "$_gac_count" != "Y" ] && [ "$_gac_count" != "y" ]; then
    return
  fi

  git add -A
  _GAC_FILES=$(git status --porcelain | awk '{print $2}')
  _GAC_LEFT_TEXT="[GITACPUSH]>"
  _GAC_BRANCH=$(git branch --show-current)
  if [ -z "$_GAC_FILES" ]; then
    echo "Nothing to commit."
    if git status | grep -q 'use "git push" to publish your local commits'; then
      echo "Commits not pushed. Pushing now."

      git push origin "$_GAC_BRANCH"
    fi
  fi

  _GAC_COUNT=$(echo "$_GAC_FILES" | wc -l | awk '{print $1}')
  _GAC_COM_FILES=""
  for _GAC_FILE in $_GAC_FILES; do
    if [ "${#_GAC_FILE}" -gt 20 ] && [ $_GAC_COUNT -gt 2 ]; then

      _GAC_TRUNCFILE=".."
      _GAC_TRUNCFILE="$_GAC_TRUNCFILE`echo $_GAC_FILE | rev | cut -c 1-10 | rev`"

      _GAC_COM_FILES="$_GAC_COM_FILES $_GAC_TRUNCFILE"

    else
      _GAC_COM_FILES="$_GAC_COM_FILES $_GAC_FILE"
    fi
  done

  _GAC_FILES=$(echo "$_GAC_FILES" | tr '\n' ' ')

  if [ $_GAC_COUNT -gt 1 ]; then
    _GAC_COUNT="`echo $_GAC_COUNT` FILES";
  elif [ $_GAC_COUNT -eq 1 ] && [ "$(echo $_GAC_FILES | sed 's/ //g')" != "" ]; then
    _GAC_COUNT="`echo $_GAC_COUNT` FILE";
  else
    _GAC_COUNT="NO FILES";
  fi

  if [ -z "$GITAC_MAX_MSG_LEN" ]; then
    # -3 for the ellipsis 72 is github's max commit msg display length
    GITAC_MAX_MSG_LEN=69 # nice
  fi

  _GAC_COMMIT_MSG="$_GAC_COUNT $_GAC_COM_FILES"

  # automatically include jira ticket number in commit message
  _GAC_SOS_SUBSTR="$(git branch --show-current)"
  if echo "$_GAC_SOS_SUBSTR" | grep -q -E '^SOS-'; then
    _GAC_COMMIT_MSG="$_GAC_COMMIT_MSG [$_GAC_SOS_SUBSTR]"
  fi

  echo $_GAC_COMMIT_MSG "\n"

  # truncate commit message if it's too long and add ellipsis
  if [ "${#_GAC_COMMIT_MSG}" -gt "$GITAC_MAX_MSG_LEN" ]; then
    _GAC_COMMIT_MSG="${_GAC_COMMIT_MSG:0:$GITAC_MAX_MSG_LEN}..."
  fi

  _GAC_COMMIT_MSG=`echo $_GAC_COMMIT_MSG | sed -E 's/ {2,}/ /g'`




  git commit -m "$_GAC_COMMIT_MSG"
  git push origin "$(git rev-parse --abbrev-ref HEAD)"
}


gitdatecommit() {
  if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ -z "$1" ]; then
    echo 'Usage: gitdatecommit [-m <commit_message>] [-d $Y-$m-$d] [-t $H:$M:$S]'
    echo "Example: ... -m 'hi' -d 2021-12-31 -t 23:59:59"
    echo ''
    return 1
  fi
  _gd_commit_message="no commit message provided"
  _gd_date_input=$(date '+%Y-%m-%d')
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

  echo "Committing with date: $_gd_date_input $_gd_time_input"

  _gd_git_date="$T${_gd_date_input}"
  _gd_git_date="${_gd_date_input}T${_gd_time_input}"


  GIT_AUTHOR_DATE="$_gd_git_date" GIT_COMMITTER_DATE="$_gd_git_date" git commit -m "$_gd_commit_message"
}


gitdateamend() {
  GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1" GIT_AUTHOR_NAME=`git config user.name` GIT_AUTHOR_EMAIL=`git config user.email` git commit --amend --no-edit --reset-author
}