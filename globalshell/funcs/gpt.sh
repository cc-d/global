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
    echo "$output"
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