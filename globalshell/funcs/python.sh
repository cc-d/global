#!/bin/sh


actvenv() {
  _ACTVENV_COUNT=0
  _ACTVENV_DIRSCANNED=0
  if [ -d "venv" ]; then
    echo "Activating venv in current directory"
    . venv/bin/activate
  else
    for d in $(find . -type d -name "venv" -maxdepth 3); do
      if [ -f "$d/bin/activate" ]; then
        _ACTVENV_FILE="$d/bin/activate"
      else
        _ACTVENV_COUNT=$(($_ACTVENV_COUNT + 1))
      fi
      _ACTVENV_DIRSCANNED=$(($_ACTVENV_DIRSCANNED + 1))
    done
    if [ -n "$_ACTVENV_FILE" ]; then
      echo "Activating virtualenv cmd: . $_ACTVENV_FILE"
      . "$_ACTVENV_FILE"
    else
      echo "No virtualenv found"
    fi
  fi
  echo "[ACTVENV]> Scanned $_ACTVENV_DIRSCANNED | Other Venvs found: $_ACTVENV_COUNT"
}
