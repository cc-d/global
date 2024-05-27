#!/usr/bin/env python3
import sys
import argparse
from typing import List, Tuple, Dict, Optional as Opt
import os.path as op
import os
from pathlib import Path as P
import subprocess as sp
import platform as plat
from glob import glob


def _sysexit(msg: str, code: int = 1):
    msg = f"{msg}"
    print(msg)
    sys.exit(code)


class GPTFile:
    __S = ['<!-- FILE: %s -->', '%s', '<!-- END: %s -->']

    def __init__(self, fname: str):
        print(f"Opening file: {fname}")
        with open(fname, 'r') as f:
            self.lines = f.readlines()
        print('\n'.join(self.lines))
        self.fname = fname
        print(self.__str__())

    def clip(self):
        copyclip(self.__str__())

    def __str__(self):
        ps = (
            '<!-- FILE: %s -->' % self.fname,
            '%s',
            '<!-- END: %s -->' % self.fname,
        )
        ps = [x % self.fname for x in self.__S]
        s = '\n'.join([ps[0]] + self.lines + [ps[2]])

        return s

    def __repr__(self):
        return self.__str__()


def copyclip(text: str):
    """Copy text to clipboard. Supports macOS and Ubuntu."""
    system = plat.system()
    if system == 'Darwin':  # macOS
        sp.run("pbcopy", text=True, input=text)
    elif system == 'Linux':  # Ubuntu
        sp.run("xclip -selection clipboard", text=True, input=text, shell=True)


def main():
    parser = argparse.ArgumentParser(
        description="Process files and copy contents to clipboard."
    )
    parser.add_argument(
        'files', metavar='files', type=str, nargs='*', help='Files to process.'
    )
    args = parser.parse_args()
    print("Arguments:", args.files)

    files, globs = [], []

    argfiles = [x for x in sys.argv[1:] if x not in ['-h', '--help']]
    print("Argument files:", argfiles)
    for f in argfiles:
        if op.isfile(f):
            print("File found:", f)
            files.append(f)
        else:
            print("Adding glob pattern:", f)
            globs.append(f)

    for g in globs:
        matched_files = glob(g)
        print("Matched files:", matched_files)
        files += matched_files

    if not files:
        _sysexit("No files found.")

    for f in files:
        if not op.isfile(f):
            continue
        print("Processing file:", f)
        gpt = GPTFile(f)
        gpt.clip()


if __name__ == '__main__':
    main()
