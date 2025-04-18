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

        _rssi = re.findall(r'\WRSSI\W+(-\d+)', std)

        self.rssi = 0 if not _rssi else int(_rssi[0])

        self.noise = re.findall(r'WNoise\W(-\d+)', std)
        self.noise = 0 if self.noise == [] else self.noise[0]
        self.date = dt.fromtimestamp(time.time())

    def __repr__(self) -> str:
        return f'{self.date.isoformat().split('.')[0]} RSSI={self.rssi}dBm Noise={self.noise}'


def main():
    polls = []

    while True:
        try:
            polls.append(
                Poll(
                    run(
                        ('sudo', 'wdutil', 'info'), capture_output=True
                    ).stdout.decode('utf8')
                )
            )
            nz_polls = [p for p in polls if p.rssi != 0]
            nz_last10 = [p for p in nz_polls[:-10] if p.rssi != 0]

            _len10 = 1 if nz_last10 == [] else len(nz_last10)

            try:
                last10_avg = round((sum(i.rssi for i in nz_last10)) / _len10)
            except ZeroDivisionError as e:
                last10_avg = 0

            print(
                f'{(polls[-1])} '
                f'{last10_avg} '
                f'({max(x.rssi for x in nz_polls)}/'
                f'{min(x.rssi for x in nz_polls)})'
            )
        except BaseException as e:
            print(e)
        sleep(0.1)


if __name__ == '__main__':
    main()
