#!/usr/bin/env python3
import sys
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


class UniqueList(list):
    __doc__ = 'List that only allows unique items.'

    def append(self, item) -> bool:
        """Append item to list if it is not already in the list.
        -> True if item was appended, False if it was already in the list.
        """
        if item not in self:
            super().append(item)
            return True
        return False

    def extend(self, i: Iterable) -> int:
        """Extend list with items in i that are not already in the list.
        -> Number of items appended.
        """
        appended = 0
        for item in i:
            if item not in self:
                super().append(item)
                appended += 1
        return appended

    def insert(self, index: int, i: Any) -> bool:
        """Insert item i at index if it is not already in the list.
        -> True if item was inserted, False if it was already in the list.
        """
        if i not in self:
            super().insert(index, i)
            return True
        return False

    def __setitem__(self, index: int, i: Any) -> bool:
        """Set item at index to i if i is not already in the list.
        -> True if item was set, False if it was already in the list.
        """
        if i not in self:
            super().__setitem__(index, i)
            return True

    def __iadd__(self, i: Iterable) -> int:
        """Add items in i to the list that are not already in the list.
        -> Number of items added.
        """
        added = 0
        for item in i:
            if item not in self:
                super().append(item)
                added += 1
        return added

    def __add__(self, i: Iterable) -> 'UniqueList':
        """Return a new UniqueList with items in i that are not already in the list."""
        newitems = set()
        for item in i:
            if item not in self:
                newitems.add(item)
        return UniqueList(self + list(newitems))

    def __eq__(self, i: U['UniqueList', Iterable]) -> bool:
        """Return True if list is equal to i, False otherwise."""
        if isinstance(i, UniqueList) or isinstance(i, list):
            if self.__sizeof__() != i.__sizeof__():
                return False
            l1len, l2len = len(self), len(i)

            if l1len != l2len:
                return False

            for i in range(l1len):
                if self[i] != i[i]:
                    return False
            return True
        else:
            return super().__eq__(i)

    def __ne__(self, i: Iterable) -> bool:
        """Return True if list is not equal to i, False otherwise."""
        return not self.__eq__(i)

    def __contains__(self, i: Any) -> bool:
        """Return True if i is in the list, False otherwise."""
        return i in self

    def __iter__(self) -> Iterable:
        """Return an iterator over the list."""
        return super().__iter__()

    def __getitem__(self, i: int) -> Any:
        """Return item at index i."""
        return super().__getitem__(i)

    def __delitem__(self, i: int) -> None:
        """Delete item at index i."""
        super().__delitem__(i)

    def clear(self) -> None:
        """Remove all items from the list."""
        super().clear()

    def copy(self) -> 'UniqueList':
        """Return a shallow copy of the list."""
        return UniqueList(super().copy())

    def count(self, i: Any) -> int:
        """Return number of occurrences of value."""
        return super().count(i)

    def index(
        self, i: Any, start: int = 0, end: int = 9223372036854775807
    ) -> int:
        """Return first index of value. Raises ValueError if the value is not present."""
        return super().index(i, start, end)

    def pop(self, index: int = -1) -> Any:
        """Remove and return item at index (default last)."""
        return super().pop(index)

    def remove(self, i: Any) -> None:
        """Remove first occurrence of value. Raises ValueError if the value is not present."""
        if i in self:
            super().remove(i)

    def reverse(self) -> None:
        """Reverse *IN PLACE*."""
        super().reverse()

    def sort(self, key: Opt[Callable] = None, reverse: bool = False) -> None:
        """Stable sort *IN PLACE*."""
        super().sort(key=key, reverse=reverse)

    def __reversed__(self) -> Iterable:
        """Return a reverse iterator over the list."""
        return super().__reversed__()

    def __mul__(self, n: int) -> 'UniqueList':
        """Return the list repeated n times."""
        return UniqueList(super().__mul__(n))

    def __rmul__(self, n: int) -> 'UniqueList':
        """Return the list repeated n times."""
        return self.__mul__(n)

    def __imul__(self, n: int) -> 'UniqueList':
        """Repeat the list n times in-place."""
        super().__imul__(n)
        return self


def read_history_file(file: str) -> List[str]:
    with open(file) as f:
        ulist = UniqueList()
        for line in f:
            if TS_HIST_RE.match(line):
                clean_line = TS_HIST_RE.sub('', line, 1)
                if clean_line.strip() and not clean_line.startswith('#'):
                    ulist.append(clean_line)
        return ulist


def main():
    histfiles = {}
    totalhist = UniqueList()
    for file in HISTORY_FILES:
        if op.exists(file):
            if file.endswith('.bash_history'):
                histfiles['bash'] = read_history_file(file)
            elif file.endswith('.zsh_history'):
                histfiles['zsh'] = read_history_file(file)
            elif file.endswith('shell_history'):
                histfiles['global'] = read_history_file(file)

    counters = {'bash': 0, 'zsh': 0, 'global': 0}
    while 'bash' in histfiles or 'zsh' in histfiles:
        add_lines = set()
        for hf in ['bash', 'zsh']:
            if hf in histfiles:
                if histfiles[hf] == []:
                    del histfiles[hf]
                    continue
                line = histfiles[hf].pop()
                if totalhist.is_unique(line):
                    add_lines.add(line)
                    counters[hf] += 1

        totalhist.extend(add_lines)


if __name__ == '__main__':
    main()
