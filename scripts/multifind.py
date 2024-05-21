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


def _search_line(line: str, args: argparse.Namespace) -> U[str, None]:
    """Handles single line in file returning the line if conditions are met."""
    matches = {}

    for search_str in args.search:
        if args.regex:
            match = re.search(
                search_str, line, re.IGNORECASE if args.ignore_case else 0
            )
            if match:
                if args.search_mode == 'or':
                    return match.group(0) if args.partial else line
                matches[search_str] = match.group(0) if args.partial else line
        else:
            search_line = line.lower() if args.ignore_case else line
            search_str = search_str.lower() if args.ignore_case else search_str
            if search_str in search_line:
                if args.search_mode == 'or':
                    return search_str if args.partial else line
                matches[search_str] = line

    if args.search_mode == 'and' and len(matches) == len(args.search):
        return line


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
                print(sline)
                _results.append(sline)
    results[filename] = _results


def thread_file_processing(
    filename: str, args: argparse.Namespace, results: dict
):
    """Process a file using multiple threads."""

    filesize = os.path.getsize(filename)
    segment_size = filesize // args.num_threads
    threads = []

    for i in range(args.num_threads):
        start = i * segment_size
        end = start + segment_size if i < args.num_threads - 1 else filesize

        thread = threading.Thread(
            target=find_in_file_segment,
            args=(filename, start, end, args, results),
        )
        threads.append(thread)
        thread.start()

    for thread in threads:
        thread.join()


def process_files(files, args):  # search, regex, partial, num_workers):
    """Setup file processing with appropriate concurrency."""
    num_workers = args.cpu
    with M.Pool(num_workers) as pool, M.Manager() as manager:
        results = manager.dict()
        procs = []
        for filename in files:
            procs.append(
                pool.apply_async(
                    thread_file_processing, (filename, args, results)
                )
            )
        while not all(proc.ready() for proc in procs):
            sleep(0.1)


def main(args):
    log_files = glob(args.files)
    process_files(log_files, args)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Log file analysis tool.')
    parser.add_argument(
        '-f',
        '--files',
        type=str,
        default='*.log',
        help='Pattern to match log files (glob)',
    )
    parser.add_argument(
        '-c',
        '--cpu',
        type=int,
        default=os.cpu_count(),
        help='Number of CPU cores to use, one file per core',
    )
    parser.add_argument(
        '-t',
        '--threads',
        type=int,
        default=4,
        help='Number of threads per file, default is 4',
        dest='num_threads',
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
        'search',
        nargs='*',
        type=str,
        help='Search string(s) to find in log files',
    )
    import sys
    import shlex

    ex = shlex.split(''.join(sys.argv[1:]))
    args = parser.parse_args()
    print(args)
    args.search_mode = args.search_mode.lower()
    main(args)
