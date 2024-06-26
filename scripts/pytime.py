#!/usr/bin/env python3
from sys import argv
from subprocess import run, PIPE
from time import perf_counter
from decimal import Decimal, getcontext
from pyshared import ran, D
from shlex import quote, split
from os import system

getcontext().prec = 12  # Set higher precision for Decimal calculations


def time_cmd(cmd):
    """Measure execution time of a shell command.
    ~cmd (str): Command to execute.
    -> Decimal: Time in seconds.
    """
    start = Decimal(perf_counter())
    result = run(split(cmd), stdout=PIPE, stderr=PIPE, text=True)
    end = Decimal(perf_counter())
    if result.stdout:
        print(result.stdout, end="")
    if result.stderr:
        print(result.stderr, end="")

    return fmt_time(end - start)


def fmt_time(e):
    """Format time in multiple units.
    ~e (Decimal): Elapsed time in seconds.
    -> str: Formatted time string.
    """
    d = {'s': D(str(e))}
    d['ms'] = d['s'] * D('1000')
    if d['s'] > D('1'):
        d['m'] = d['s'] / D('60')
        if d['m'] > D('1'):
            d['h'] = d['m'] / D('60')
            if d['h'] > D('1'):
                d['d'] = d['h'] / D('24')

    for k, v in d.items():
        if str(float(v)).endswith('.0'):
            d[k] = int(v)

    t = 'pytime: '

    for k in ['ms', 's', 'm', 'h', 'd']:
        if k not in d:
            break
        r = 3 if k == 's' else 2

        if k in d:
            num = f'{0 if round(d[k], r) == 0 else  round(d[k],r)}'
            s = f'{num}{k}'
            if len(str(num).split('.')[0]) >= 5:
                continue

            t += s + ' '

    return t


def test():
    times = [
        ran.randint(0, 100) * ran.choice([0.0001, 1, 0.0099])
        for _ in range(50)
    ]
    ts = ''
    for i in times:
        ts += fmt_time(i).replace('pytime: ', '')
        if len(ts) > 100:
            print(ts)
            ts = ''


if __name__ == "__main__":
    if len(argv) < 2 or argv[1] in ['-h', '--help']:
        print("Usage: pytime <command>")
    else:
        print('\n', time_cmd(' '.join(argv[1:])), '\n')
