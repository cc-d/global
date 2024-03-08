#!/usr/bin/env python3
import os
import sys
import os.path as op
from time import sleep
from typing import List, Tuple, Optional as Opt

GSHISTORY = op.expanduser('~/.global/shell_history')
try:
    _PAD = max(os.get_terminal_size().columns // 3, 10)
except OSError:
    _PAD = 10
GHHEADER = '=' * _PAD + ' GLOBAL HISTORY ' + '=' * _PAD


class NoHistoryFileError(FileNotFoundError):
    pass


def history_files() -> List[str]:
    """return the path of the history file for the current shell"""
    history_files = []
    _hfiles = {
        'bash': op.expanduser('~/.bash_history'),
        'zsh': op.expanduser('~/.zsh_history'),
        'fish': op.expanduser('~/.local/share/fish/fish_history'),
    }
    for k, v in _hfiles.items():
        if op.exists(v):
            history_files.append(v)

    if len(history_files) > 0:
        return history_files

    raise NoHistoryFileError('Could not guess history file')


def _ensure_gh_file(gsfile: str = GSHISTORY) -> bool:
    """ensures that the global history file exists"""
    if not op.exists(gsfile):
        print(f'Creating global history file: {gsfile}')
        os.makedirs(op.dirname(gsfile), exist_ok=True)
        with open(gsfile, 'w') as f:
            f.write('')
            return False
    return True


def ghfile_unique(gsfile: str = GSHISTORY) -> List[str]:
    """Ensure that the global history file contains only unique lines"""
    _ensure_gh_file(gsfile)

    uniq_lines, all_lines = [], []
    with open(gsfile, 'r') as f:
        for line in f.read().splitlines():
            all_lines.append(line)
            if line not in uniq_lines:
                uniq_lines.append(line)

    if len(uniq_lines) != len(all_lines):
        print(f'{len(all_lines) - len(uniq_lines)} dupicate lines in {gsfile}')
        print(f'Removing duplicates from {gsfile}')
        with open(gsfile, 'w') as f:
            print(f'writing {len(uniq_lines)} unique lines to {gsfile}')
            f.write('\n'.join(uniq_lines))

    return uniq_lines


def update_ghistory() -> List[str]:
    hfiles = history_files()

    combined_history = []
    for hfile in hfiles:
        with open(hfile, 'r') as f:
            for line in f.read().splitlines():
                if line.strip() != '' and not line.startswith('#'):
                    if line not in combined_history:
                        combined_history.append(line)

    print(GHHEADER)
    print(f'History Files: {hfiles} | {len(combined_history)} lines')

    ghlines, newlines = ghfile_unique(), []

    for line in combined_history:
        if line not in ghlines:
            newlines.append(line)

    if len(newlines) > 0:
        print(f'Adding {len(newlines)} lines to {GSHISTORY}')
        print(GHHEADER)
        print('\n'.join(newlines))
        with open(GSHISTORY, 'w') as f:
            f.write('\n'.join(ghlines + newlines) + '\n')
            print(GHHEADER)
            print(f'Added {len(newlines)} lines to {GSHISTORY}')

    return newlines


def main(poll_every: Opt[int] = None):
    if poll_every is not None:
        while True:
            update_ghistory()
            sleep(poll_every)
    else:
        update_ghistory()


def print_history():
    with open(GSHISTORY, 'r') as f:
        lines = set(f.read().splitlines())
        for i, line in enumerate(lines):
            print(f'{i} {line}')


if __name__ == '__main__':
    if len(sys.argv) > 1:
        if str(sys.argv[1]).lower() == 'print':
            print_history()
        else:
            main(int(sys.argv[1]))
    else:
        main()
