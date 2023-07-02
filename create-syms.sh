#!/usr/bin/env bash

if [ -e '$GLOBALDIR' ]; then
    eval 'cd $GLOBALDIR && $(
        if [ -d $GLOBALDIR/syms ]; then
            rm -r $GLOBALDIR/syms && mkdir -p $GLOBALDIR/syms
        fi

        ln -s $GLOBALDIR/76.sh $GLOBALDIR/syms/76)
        ln -s $GLOBALDIR/evar.sh $GLOBALDIR/syms/evar)
        ln -s $GLOBALDIR/ftemplate.py $GLOBALDIR/syms/ftemplate)
        ln -s $GLOBALDIR/gcpports.sh $GLOBALDIR/syms/gcpports)
        ln -s $GLOBALDIR/gcpssh.sh $GLOBALDIR/syms/gcpssh)
        ln -s $GLOBALDIR/gitconf.sh $GLOBALDIR/syms/gitconf)
        ln -s $GLOBALDIR/gpull.sh $GLOBALDIR/syms/gpull)
        ln -s $GLOBALDIR/gpush.sh $GLOBALDIR/syms/gpush)
    )'
fi



