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

publish_to_pypi() {
    # Check if setup.py exists
    if [ -f "setup.py" ] && ! [ -f "pyproject.toml" ]; then
        python setup.py sdist bdist_wheel
    else
        # Check if pyproject.toml exists
        if [ -f "pyproject.toml" ]; then
            python -m build
        else
            echo "Neither setup.py nor pyproject.toml found."
            return 1
        fi
    fi

    # Check if build directory exists
    if [ -d "dist" ]; then
        # Find the most recent build file in the dist directory
        most_recent_build=$(ls -tv dist/* 2>/dev/null | head -n 2 | tr '\n' ' ')
        most_recent_version=$(echo $most_recent_build | grep -oE '[^ ]+\d+\.\d+\.\d+' | head -n 1)

        if [ -n "$most_recent_build" ]; then
            # Read PyPI token from file
            if ! [ -n "$PYPI_TOKEN_FILE" ]; then
                echo "PYPI_TOKEN_FILE not set."
                return 1
            fi

            pypi_token=$(cat "$PYPI_TOKEN_FILE")

            # Upload the most recent build using environment variables for authentication
            echo "Uploading build to PyPI..."
            echo "Using PyPI token from file: $PYPI_TOKEN_FILE"
            echo "Uploading build: $most_recent_build"
            echo "Most recent version: $most_recent_version"
            TWINE_USERNAME="__token__" TWINE_PASSWORD="$pypi_token" twine upload $most_recent_version*

        else
            echo "No build files found in 'dist' directory."
            return 1
        fi
    else
        echo "Build directory 'dist' not found."
        return 1
    fi
}


