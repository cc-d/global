#!/usr/bin/env python3
import sys
from glob import glob
import os.path as op
import sys
import re
from typing import (
    List,
    Tuple,
    Optional as Opt,
    Union as U,
    Any,
    Iterable,
    Callable,
)
from itertools import zip_longest

GHHEADER = '=' * 10 + ' GLOBAL HISTORY ' + '=' * 10
GHFILE = op.expanduser('~/.global/shell_history')
HISTORY_FILES = [
    op.expanduser('~/.bash_history'),
    op.expanduser('~/.zsh_history'),
]

TS_HIST_RE = re.compile(r'^:\s+\d+:\d+;')


def read_history_file(file: str) -> List[str]:
    if not op.exists(file):
        return []

    with open(file) as f:
        ulist = list()
        for line in f.read().splitlines():
            clean_line = line
            if TS_HIST_RE.match(clean_line):
                clean_line = TS_HIST_RE.sub('', clean_line, 1)

            if clean_line.strip() and not clean_line.startswith('#'):
                if clean_line not in ulist:
                    ulist.append(clean_line)
        return ulist


def _interleave(*iterables: Iterable) -> List:
    new_list = list()
    new_iters = [list(i) for i in iterables]
    while sum(len(i) for i in new_iters) > 0:
        for i in new_iters:
            if len(i) > 0:
                new_line = i.pop(0)
                if new_line not in new_list:
                    new_list.append(new_line)

    return new_list


def main():
    print(GHHEADER)
    bhist = read_history_file(HISTORY_FILES[0])
    zhist = read_history_file(HISTORY_FILES[1])
    for f in glob(op.expanduser('~/.zsh_sessions/*.hist*')):
        session_hist = read_history_file(f)
        for l in session_hist:
            if l not in zhist:
                zhist.append(l)

    non_ghist = _interleave(bhist, zhist)
    ghist = read_history_file(GHFILE)
    new_lines = [l for l in non_ghist if l not in ghist]

    if new_lines:
        print('writing %s new lines to %s' % (len(new_lines), GHFILE))
        with open(GHFILE, 'a') as f:
            f.write('\n'.join(new_lines) + '\n')
    else:
        print('no new lines to write')


if __name__ == '__main__':
    main()


# The script reads the history files of bash and zsh, and the history files of zsh sessions. It then interleaves the lines from the bash and zsh history files, and compares the interleaved history with the global history file. If there are new lines, it writes them to the global history file. The script is useful for maintaining a global history file that contains all the unique commands from all the history files.
