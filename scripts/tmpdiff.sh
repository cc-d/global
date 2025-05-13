#!/bin/sh

f1=`mktemp`
f2=`mktemp`

exec > $f1
$@
exec > /dev/tty

read -p "Continue>"

exec > $f2
$@
exec > /dev/tty


diff $f1 $f2
