#!/usr/bin/env python3
import sys
from random import *
from time import *

MIL = 1000000

def dec(func):
    def fwrapped(*args, **kwargs):
        t = time()
        r = func(*args, **kwargs)
        st = time() - t
        print(str(r)[0:100], ' | ', st)
        return r
    return fwrapped

@dec
def rnums(nlen):
    return [randint(0, nlen) for x in range(nlen)]

def main():
    
    rnums(MIL)


if __name__ == '__main__':
    main()

