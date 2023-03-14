#!/usr/bin/env python3
import sys
from concurrent.futures import ThreadPoolExecutor
import threading
from random import *
from time import *

MIL = 10000000
TCOUNT = 8
INC = MIL // TCOUNT


def ftime(func):
    def fwrap(*args, **kwargs):
        t1 = time()
        r = func(*args, **kwargs)
        print(f'{func.__name__}() {time() - t1}')
        return r
    return fwrap


@ftime
def ran_nums(n=MIL, nmax=100):
    return [randint(0, nmax) for x in range(n)]


@ftime
def mran_nums(n=MIL, nmax=100):
    nums = []
    chunk_size = n // TCOUNT
    results = []

    def nrange(start, end, nums):
        nums.extend([randint(0, nmax) for x in range(start, min(start + chunk_size, MIL))])

    threads = []
    for i in range(TCOUNT):
        start = i * chunk_size
        end = start + chunk_size if i < TCOUNT - 1 else MIL
        thread = threading.Thread(target=nrange, args=(start, start + chunk_size, nums))
        thread.start()  
        threads.append(thread)

    for t in threads: t.start()

    for thread in threads:
        thread.join()
        thread.r
        print('join', thread)

    return nums


def main():
    ran_nums()
    mran_nums()

if __name__ == '__main__':
    main()

