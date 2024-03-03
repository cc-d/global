#!/usr/bin/env python3
import os
import os.path as op
import sys
import gzip as gz
import shutil as sh

OUTFILE = 'combined.txt'


def _padprint(*args, **kwargs):
    print('=' * 20, *args, '=' * 20, **kwargs)


def extract_lines(*args, del_out=True):
    lines_out = []
    if len(args) == 0:
        print('no files provided, looking for access.log files in curdir')
        args = [f for f in os.listdir() if f.startswith('access.log')]

    print('combining files into', OUTFILE)
    if del_out and op.exists(OUTFILE):
        print('deleting existing', OUTFILE)
        os.remove(OUTFILE)

    with open(OUTFILE, 'a+') as f_out:
        for arg in args:
            print('gz file', arg)
            if arg.endswith('.gz'):
                print('extracting from', arg)
                with gz.open(arg, 'rb') as f_in:
                    lines = f_in.readlines()
                    for line in lines:
                        line = line.decode('utf-8')
                        lines_out.append(line)
                        f_out.write(line)
            else:
                print('non-gz file', arg)
                with open(arg, 'r') as f_in:
                    lines = f_in.readlines()
                    for line in lines:
                        lines_out.append(line)
                        f_out.write(line)

    _padprint('SUMMARY')
    outdict = {
        'lout_len': len(lines_out),
        'lout': lines_out,
        'fin': args,
        'fin_len': len(args),
        'out': OUTFILE,
        'out_len': len(open(OUTFILE).readlines()),
        'out_size': str(round(op.getsize(OUTFILE) / 1024 / 1024, 2)) + ' MB',
        'uniq': len(set(lines_out)),
    }
    print(
        ' | '.join(
            f'{k}: {v}' for k, v in outdict.items() if len(str(v)) < 100
        )
    )
    _padprint('=' * 10, sep='')


if __name__ == "__main__":
    extract_lines(*sys.argv[1:])
