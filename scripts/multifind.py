#!/usr/bin/env python3
import argparse
import os
import multiprocessing as M
import threading
import re
from time import sleep
from glob import glob
from typing import List


def find_in_file_segment(
    filename, start, end, search_str, regex, partial, results
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
            if regex:
                match = re.search(search_str, line)
                if match:
                    _results.append(match.group(0) if partial else line)
                    print(_results[-1])
            else:
                if search_str in line:
                    _results.append(search_str if partial else line)
                    print(_results[-1])

    results[filename] = _results


def thread_file_processing(
    filename, search_str, regex, partial, num_threads, results
):
    """Process a file using multiple threads."""

    filesize = os.path.getsize(filename)
    segment_size = filesize // num_threads
    threads = []

    for i in range(num_threads):
        start = i * segment_size
        end = start + segment_size if i < num_threads - 1 else filesize

        thread = threading.Thread(
            target=find_in_file_segment,
            args=(filename, start, end, search_str, regex, partial, results),
        )
        threads.append(thread)
        thread.start()

    for thread in threads:
        thread.join()


def process_files(files, search_str, regex, partial, single, num_workers):
    """Setup file processing with appropriate concurrency."""

    if single:
        for filename in files:
            thread_file_processing(filename, search_str, regex, partial, 2)
    else:
        with M.Pool(num_workers) as pool, M.Manager() as manager:
            results = manager.dict()
            for filename in files:
                pool.apply_async(
                    thread_file_processing,
                    (
                        filename,
                        search_str,
                        regex,
                        partial,
                        num_workers,
                        results,
                    ),
                )
            while len(results) < len(files):
                sleep(0.1)


def main(args):
    log_files = glob(args.file_pattern)
    for s in args.search:
        print(f'Searching for "{s}" in {len(log_files)} files')

        process_files(
            log_files, s, args.regex, args.partial, args.single, args.cpu
        )


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Log file analysis tool.')
    parser.add_argument(
        '-f',
        '--file_pattern',
        type=str,
        default='*.log',
        help='Pattern to match log files',
    )
    parser.add_argument(
        '-c',
        '--cpu',
        type=int,
        default=os.cpu_count(),
        help='Number of CPUs to use for processing',
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
        '-s',
        '--single',
        action='store_true',
        help='Process files one at a time',
    )
    parser.add_argument(
        'search', nargs='+', help='Search strings to look for in the files'
    )
    args = parser.parse_args()
    main(args)
