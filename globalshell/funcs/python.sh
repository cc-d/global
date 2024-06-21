#!/bin/sh


findvenv() {

    _av_venv=`find . -type f -path '*/venv/bin/activate' -maxdepth 5| head -n 1`
    if [ -n "$_av_venv" ]; then
        _venv_dir=`find .. -type d -path '*/venv' -maxdepth 1 | head -n 1`
    fi

    if [ -n "$_av_venv" ]; then
        echo "$_av_venv"
        return 0
    fi
    return 1

}

actvenv() {
    _av_venv=`findvenv`
    if [ -n "$_av_venv" ]; then
        . $_av_venv
        return 0
    fi
    return 1
}




recvenv() {
    deactivate
    _av_venv=`findvenv`
    if [ -n "$_av_venv" ]; then
        echo "Found virtualenv: $_av_venv"
        _venv_dir=`echo $_av_venv | sed -E 's|[a-zA-Z0-9]+/bin/activate||'`
        echo "CDing to venv directory... $_venv_dir"
        cd $_venv_dir
        echo "Recreating virtualenv..."
    fi
    echo "Creating virtualenv..."
    mkactvenv
    echo "Installing requirements..."
    _rv_recfile=`find . -type f -name 'req*.txt' -maxdepth 2 | head -n 1 | sed -E 's/^\.?\/?//'`

    if [ -n "$_rv_recfile" ]; then
        echo "Found requirements file: $_rv_recfile"
        if pwd | grep pict; then
            _cmdflags="--use-deprecated=legacy-resolver"
        else
            _cmdflags=""
        fi

        echo "Running: pip3 install -r $_rv_recfile $_cmdflags"
        pip3 install -r $_rv_recfile $_cmdflags
    else
        echo "No requirements file found."
    fi


    return 1
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
        echo "Most recent build: $most_recent_build"
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
            TWINE_USERNAME="__token__" TWINE_PASSWORD="$pypi_token" twine upload --verbose $most_recent_version*

        else
            echo "No build files found in 'dist' directory."
            return 1
        fi
    else
        echo "Build directory 'dist' not found."
        return 1
    fi
}


