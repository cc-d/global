#!/usr/bin/env bash
rm -r $PWD/syms
mkdir $PWD/syms

ln -s $PWD/76.sh $PWD/syms/76
ln -s $PWD/evar.sh $PWD/syms/evar
ln -s $PWD/ftemplate.py $PWD/syms/ftemplate
ln -s $PWD/gcpports.sh $PWD/syms/gcpports
ln -s $PWD/gcpssh.sh $PWD/syms/gcpssh
ln -s $PWD/gitconf.sh $PWD/syms/gitconf
ln -s $PWD/gpull.sh $PWD/syms/gpull
ln -s $PWD/gpush.sh $PWD/syms/gpush

