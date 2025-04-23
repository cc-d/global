#!/usr/bin/env python3

import re
from time import sleep
from subprocess import run
from typing import Iterable as Iter
from datetime import datetime as dt, timezone as tz
import time


class Poll:
    rssi: int
    noise: int
    date: dt

    def __init__(self, std: str):

        _rssi = ''.join(re.findall(r'\WRSSI\W+: (-{0,1}\d+) dBm', std))

        self.rssi = 0 if not _rssi else int(_rssi)

        self.noise = ''.join(re.findall(r'\WNoise\W+: (-{0,1}\d+) dBm', std))
        self.noise = 0 if not self.noise else int(self.noise)
        self.date = dt.fromtimestamp(time.time())

    def __repr__(self) -> str:
        return f'{self.date.isoformat().split('.')[0]} {self.rssi}dBm {self.noise}'


def main():
    polls = []

    while True:
        try:
            polls.append(
                Poll(
                    run(
                        ('sudo', 'wdutil', 'info'),
                        capture_output=True,
                        check=True,
                    ).stdout.decode('utf8')
                )
            )
            nz_polls = [p for p in polls if p.rssi != 0]

            print(
                f'{(polls[-1])} '
                f'({max(x.rssi for x in nz_polls)}/'
                f'{min(x.rssi for x in nz_polls)}) '
                f'[{''.join(reversed([str(x.rssi) for x in polls[-11:][:-1]]))}]'
            )

        except BaseException as e:
            print(e)
        sleep(1)


if __name__ == '__main__':
    main()
