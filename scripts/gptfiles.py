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
from unittest.mock import patch


def _sysexit(msg: str, code: int = 1):
    msg = f"{msg}"
    print(msg)
    sys.exit(code)


class GPTFile:
    __S = ['\n<!-- FILE: %s -->\n', '\n<!-- END: %s -->\n']

    def __init__(self, fname: str):

        with open(fname, 'r') as f:
            self.__lines = f.read().splitlines()
            self.__lines = [l for l in self.__lines if l.strip()]
            self.__lines = [
                l for l in self.__lines if not l.strip().startswith('#')
            ]
        self.fname = fname

    def clip(self):
        copyclip(self.__str__())

    def __str__(self):
        return self.__S

    def __repr__(self):
        return self.__str__()

    @property
    def lines(self):
        return self.__lines


def copyclip(text: str):
    """Copy text to clipboard. Supports macOS and Ubuntu."""
    system = plat.system()

    if system == 'Darwin':  # macOS
        with patch('builtins.print') as p:
            sp.run("pbcopy", text=True, input=text, shell=True)

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

    files, globs = [], []

    argfiles = [x for x in sys.argv[1:] if x not in ['-h', '--help']]

    for f in argfiles:
        if P(f).parts[-1] == '.gptfiles':
            with open(f, 'r') as gptf:
                argfiles += gptf.read().split()

    for f in argfiles:
        files.append(f) if op.isfile(f) else globs.append(f)

    for g in globs:
        matched_files = glob(g)
        files += matched_files

    if not files:
        _sysexit("No files found.")

    clip = []
    for f in files:
        print(f)
        if not op.isfile(f):
            continue

        gpt = GPTFile(f)
        clip.append(f'<!-- FILE: {f} -->')
        for l in gpt.lines:
            clip.append(l)
        clip.append(f'<!-- END: {f} -->')

    if not clip:
        _sysexit("No files found.")

    print(len(clip), "lines copied to clipboard.")
    copyclip('\n'.join([c for c in clip if c.strip()]))


if __name__ == '__main__':
    main()
