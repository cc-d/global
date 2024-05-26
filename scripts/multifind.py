#!/usr/bin/env python3
import argparse
import os
import multiprocessing as M
import threading
import re
from time import sleep
from glob import glob
from typing import List, Optional as Opt, Union as U
from logfunc import logf


def _verbose(msg: str, args: argparse.Namespace):
    if args.verbose:
        print(msg)


def _sl_regex(
    line: str, args: argparse.Namespace, matches: dict = {}
) -> U[str, None]:
    """Search line using regex."""

    for search_str in args.search:
        match = re.search(
            search_str, line, re.IGNORECASE if args.ignore_case else 0
        )
        if match:
            if args.search_mode == 'or':
                return match.group(0) if args.partial else line
            else:
                matches[search_str] = match.group(0) if args.partial else line
    if args.search_mode == 'and' and len(matches) == len(args.search):
        return line


def _sl_substr(
    line: str, args: argparse.Namespace, matches: dict = {}
) -> U[str, None]:
    """Search line using substring."""
    for search_str in args.search:
        search_line = line.lower() if args.ignore_case else line
        search_str = search_str.lower() if args.ignore_case else search_str
        if search_str in search_line:
            if args.search_mode == 'or':
                return search_str if args.partial else line
            else:
                matches[search_str] = line
    if args.search_mode == 'and' and len(matches) == len(args.search):
        return line


def _search_line(line: str, args: argparse.Namespace) -> U[str, None]:
    """Handles single line in file returning the line if conditions are met."""
    if args.regex:
        return _sl_regex(line, args)
    return _sl_substr(line, args)


def find_in_file_segment(
    filename: str,
    start: int,
    end: int,
    args: argparse.Namespace,
    results: dict,
):
    """Find the search string in a file segment from start to end."""

    _results = []
    with open(filename, 'r') as file:
        file.seek(start)
        if start != 0:
            file.readline()  # Move to the start of the next line to avoid partial lines
        while file.tell() < end:
            line = file.readline()
            if file.tell() > end:
                break
            sline = _search_line(line, args)
            if sline:
                print(sline.rstrip())
                _results.append(sline)
    results[filename] = _results


def spawn_threads(
    filename: str,
    args: argparse.Namespace,
    results: dict,
    procs: dict,
    start: int,
    end: int,
    segsize: int,
):
    """Spawn a thread to process a segment of a file."""
    _verbose(f'Starting threads for range {start} - {end} in {filename}', args)

    tresults = {}
    find_in_file_segment(filename, start, end, args, tresults)
    return tresults


def spawn_procs(
    filename: str,
    args: argparse.Namespace,
    pool: M.Pool,
    procs: dict,
    manager: M.Manager,
    results: list,
):
    """Process a file using multiple processes."""

    # get line count

    segment_size = os.path.getsize(filename) // args.cpu
    _procs = []

    for i in range(0, args.cpu):
        start = i * segment_size
        end = (i + 1) * segment_size

        _verbose(f'Starting process for {filename} segment {i}', args)
        _procs.append(
            pool.apply_async(
                spawn_threads,
                args=(
                    filename,
                    args,
                    results,
                    procs,
                    start,
                    end,
                    segment_size,
                ),
            )
        )

    while not all(p.ready() for p in _procs):
        sleep(0.1)

    return results


def proc_single_file(fname, args):
    """Process a single file."""

    with M.Pool(args.cpu) as pool, M.Manager() as manager:
        procs = manager.dict({'threads': [], 'procs': []})
        results = manager.list()
        spawn_procs(fname, args, pool, procs, manager, results)


def main(args):
    log_files = glob(args.files)
    if len(log_files) == 0:
        print('No files found')
        return
    for f in log_files:
        proc_single_file(f, args)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Log file analysis tool.')
    parser.add_argument(
        '-f',
        '--files',
        type=str,
        required=True,
        help='File or files to search',
    )

    parser.add_argument(
        '-c',
        '--cpu',
        type=int,
        default=M.cpu_count() // 4 * 3,
        help='Number of CPU cores to use. Defaults to roughly 3/4 of cores',
    )

    parser.add_argument(
        '-r', '--regex', action='store_true', help='Use regex for searching'
    )
    parser.add_argument(
        '-p',
        '--partial',
        action='store_true',
        help='Display only matches, not full lines',
    )
    parser.add_argument(
        '-m',
        '--search-mode',
        choices=['and', 'or'],
        default='or',
        help='Search mode to use, default is AND',
        type=str,
        dest='search_mode',
    )
    parser.add_argument(
        '-i',
        '--ignore-case',
        action='store_true',
        help='Ignore case when searching',
    )
    parser.add_argument(
        '-v', '--verbose', action='store_true', help='Verbose output'
    )
    parser.add_argument(
        'search',
        nargs='*',
        type=str,
        help='Search string(s) to find in log files',
    )

    import sys
    import shlex

    ex = shlex.split(''.join(sys.argv[1:]))
    args = parser.parse_args()

    args.search_mode = args.search_mode.lower()
    main(args)
