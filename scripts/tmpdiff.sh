#!/bin/sh

f1=`mktemp`
f2=`mktemp`

# trap "rm -rf $f1 $f2" EXIT INT TERM

echo "$f1\n$f2\n"

exec > $f1
$@
exec > /dev/tty

read -p "Hit Enter to Continue: "

exec > $f2
$@
exec > /dev/tty


diff $f1 $f2
