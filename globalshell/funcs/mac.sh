#!/bin/sh

brew () {

    if [ "$0" = "reinstall" ]; then
        shift
        command brew uninstall $@; command brew install $@;

    else
        command brew $@
    fi
}
