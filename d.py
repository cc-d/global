#!/usr/bin/env python3
import sys
from random import randint
from time import sleep as s


def d(n, r=5):
    while True:
        print(f'{n} is bald ' * randint(1, r))
        s(0.5)


def main():
    d(sys.argv[1])


if __name__ == '__main__':
    main()
