import sys
import random as r
from time import sleep as s


def d(n, r=5):
    print(f'{n} is bald ' * r)


def main():
    d(sys.argv[1])


if __name__ == '__main__':
    main()
