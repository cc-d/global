#!/bin/sh


actvenv() {
  venvfile=$(find . -name 'activate' | head -n 1 | sed -E 's/^\.\//. /')
  if [ -z "$venvfile" ]; then
    echo "No virtualenv found."
    return 1
  else
    eval "$venvfile"
  fi
}
