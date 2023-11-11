#!/usr/bin/env python3
import os
import sys
from typing import List, Optional, Set


def colwidth(ncols: int) -> int:
    """Returns the width of each column in characters -1"""
    return os.get_terminal_size().columns // ncols - 1


class DEFAULTS:
    ncols = 4
    colw = colwidth(ncols)


def columnate(
    ncols: int = DEFAULTS.ncols, colw: int = colwidth(DEFAULTS.ncols)
) -> Set[str]:
    """Prints stdin in columns defaulting to 4 columns and
    automatically adjusting the column width to fit the terminal
    """

    printed = set()

    while True:
        line = sys.stdin.readline()
        if not line:
            break

        line = line.rstrip()

        if len(line) > colw:
            line = line[: colw - 1] + "…"
        else:
            line = line.ljust(colw)

        if line not in printed:
            print(line, end=" ")
            printed.add(line)

    print()
    return printed


def main() -> None:
    columnate()


if __name__ == "__main__":
    main()
