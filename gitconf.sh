#!/bin/sh

NAME="Cary Carter"
EMAIL="$2"

echo $1

if [ -z "$EMAIL" ]
then
    echo "Please provide an email address"
    exit 1
fi

if [ "$1" = "global" ]
then
    git config --global user.name "$NAME"
    git config --global user.email "$EMAIL"
    echo "Global git config updated with name/email: $NAME $EMAIL"
elif [ "$1" = "local" ]
then
    git config --local user.name "$NAME"
    git config user.email "$EMAIL"
    echo "Local git config updated with name/email: $NAME $EMAIL"
elif [ "$1" = "system" ]
then
    git config --system user.name "$NAME"
    git config --system user.email "$EMAIL"
    echo "System git config updated with name/email: $NAME $EMAIL"
else
    echo "Invalid option: use 'global', 'local', or 'system'"
fi
