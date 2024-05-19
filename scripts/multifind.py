#!/usr/bin/env python3
import argparse
import os
import multiprocessing as M
import threading
import re
from glob import glob
from typing import List


os.environ['LOGF_USE_PRINT'] = 'True'


from logfunc import logf


def find_in_file_segment(
    filename, start, end, search_str, regex, partial, results
):
    """Find the search string in a file segment from start to end."""
    startr = len(results)
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
                    result = match.group(0) if partial else line
                    results.append(result)
            else:
                if search_str in line:
                    result = search_str if partial else line
                    results.append(result)


def thread_file_processing(filename, search_str, regex, partial, num_threads):
    """Process a file using multiple threads."""
    results = []
    filesize = os.path.getsize(filename)
    segment_size = filesize // num_threads
    threads = []

    for i in range(2):
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

    for result in results:
        print(result)


def process_files(files, search_str, regex, partial, single, num_workers):
    """Setup file processing with appropriate concurrency."""
    if single:
        for filename in files:
            thread_file_processing(filename, search_str, regex, partial, 1)
    else:
        with M.Pool(num_workers) as pool:
            for filename in files:
                pool.apply_async(
                    thread_file_processing,
                    (filename, search_str, regex, partial, num_workers),
                )


def main(args):
    log_files = glob(args.file_pattern)
    for s in args.search:
        print(f'Searching for "{s}" in {len(log_files)} files')

        process_files(
            log_files, s, args.regex, args.partial, args.single, args.cpu
        )


for func in [
    main,
    process_files,
    thread_file_processing,
    find_in_file_segment,
]:
    globals()[func.__name__] = logf()(func)


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
