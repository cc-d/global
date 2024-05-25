#!/usr/bin/env python3
import sys
import os.path as op
import sys
from typing import List, Tuple, Optional as Opt
from itertools import zip_longest

GHHEADER = '=' * 10 + ' GLOBAL HISTORY ' + '=' * 10
GHFILE = op.expanduser('~/.global/shell_history')
HISTORY_FILES = [
    op.expanduser('~/.bash_history'),
    op.expanduser('~/.zsh_history'),
]


def read_histfile(hfile: str) -> List[str]:
    """reads history file and returns a list of lines"""
    lines, ulines = [], []
    if not op.exists(hfile):
        return ulines

    with open(hfile, 'r', errors='ignore') as f:
        lines = f.read().splitlines()
    while lines:
        line = lines.pop(0)
        if line not in ulines and line.strip() and not line.startswith('#'):
            ulines.append(line)

    return ulines


def _merge_lines(*args: List[str]) -> set:
    """merges lines from multiple history files"""
    merged = set()
    for lines in zip_longest(*args):
        for line in lines:
            if line:
                merged.add(line)

    return merged


def main(*args: str) -> None:
    history = _merge_lines(*[read_histfile(hfile) for hfile in HISTORY_FILES])
    ghistory = read_histfile(GHFILE)
    new_history = [line for line in history if line not in ghistory]

    print(GHHEADER)
    if new_history:
        print(f'Found new lines, adding to {GHFILE}')
        ghistory.extend(new_history)
        with open(GHFILE, 'w') as f:
            f.write('\n'.join(ghistory))

    limit = int(args[0]) if args else None
    linemap = list((i, line) for i, line in enumerate(ghistory))
    if limit:
        while len(linemap) > limit:
            linemap.pop(0)

    for ln in linemap:
        print(*ln)


if __name__ == '__main__':
    main(*sys.argv[1:])
