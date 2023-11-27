#!/bin/sh

echo_gptfile() {
  title="<<! FILE: $1 !>>"
  if [ ! -f "$1" ]; then
    return 1
  fi
  content=$(cat "$1" | awk '!/^[[:space:]]*$/' | sed -E 's/^.*#.*//g' )

  if [ -z "$content" ]; then
    echo "(empty) $title"
  else
    echo ''
    echo "$title"
    echo '''```'''
    echo "$content"
    echo '''```'''

  fi
}

gptfiles() {
  output=""
  os_arch=$(ostype)
  os_type=$(echo "$os_arch" | awk '{print $1}')

  for f in "$@"; do
    output="$output$(echo_gptfile $f)"
  done

  if `uname -s | grep -qi "darwin"`; then
    echo -e "$output" | pbcopy
  else
    echo -e "$output" | xclip -selection clipboard
  fi

  echo -e "$output"
  echo "Copied to clipboard"
  echo ''
}