#!/usr/bin/env python3
from sys import argv
from subprocess import run
from time import perf_counter
from decimal import Decimal, getcontext

getcontext().prec = 12  # Set higher precision for Decimal calculations


def time_cmd(cmd):
    """Measure execution time of a shell command.
    ~cmd (str): Command to execute.
    -> Decimal: Time in seconds.
    """
    start = Decimal(perf_counter())
    run(cmd, shell=True, check=False)
    return fmt_time(Decimal(perf_counter()) - start)


def fmt_time(e):
    """Format time in multiple units.
    ~e (Decimal): Elapsed time in seconds.
    -> str: Formatted time string.
    """

    td = {
        'ms': round(e * 1000, 2),
        's': round(e, 2),
        'm': round(e / 60, 2),
        'h': round(e / 3600, 2),
        'd': round(e / 86400, 2),
    }
    ts = 'time: '
    for k, v in td.items():
        if set(str(v)) != {'0', '.'} and v > 0.1:
            ts += '%s%s ' % (v, k)

    return ts.strip()


if __name__ == "__main__":
    if len(argv) < 2:
        print("Usage: pytime <command>")
    else:

        print(time_cmd(" ".join(argv[1:])))
