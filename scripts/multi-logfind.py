#!/usr/bin/env python3
import sys
import threading as T
import multiprocessing as M
from multiprocessing.pool import ApplyResult, Pool, AsyncResult, IMapIterator
from logfunc import logf
import os
import os.path as op
import sys
from time import sleep

LIMIT = max(4, M.cpu_count())
logfiles = [
    x
    for x in os.listdir(os.getcwd())
    if x.find('.log') != -1 and x.find('part') != -1
]


def find_in_lines(file, s, q):
    _total = 0
    with open(file, 'r') as f:
        for line in f:
            _total += 1
            if line.find(s) != -1:
                print('adding line to queue', line[0:100], 'file', file)
                q.put(line)
    return _total


@logf()
def find_all_files(s):

    with M.Manager() as mgr, M.Pool(LIMIT) as pool:
        q = mgr.Queue()
        procs = []
        results = []

        for file in logfiles:
            # print('spawning process for', file)
            procs.append(pool.apply_async(find_in_lines, (file, s, q)))

        # q.join()
        while True:
            ready = [p for p in procs if p.ready()]
            # print('ready', len(ready))
            if q.qsize():
                while not q.empty():

                    results.append(q.get(False))

            if not ready:
                sleep(0.2)
            else:
                if all([p.ready() for p in procs]):
                    if all([p.successful() for p in procs]):
                        # print([str(p.get())[0:100] for p in procs])
                        # print('all processes finished')
                        return results


@logf()
def main():
    if len(sys.argv) >= 2:
        find_strs = sys.argv[1:]

    for s in find_strs:
        print(f'\nsearching for all lines containing {s}\n')
        for l in find_all_files(s):
            print(l)


if __name__ == '__main__':
    main()
