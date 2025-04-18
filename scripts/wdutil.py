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

        _rssi = re.findall(r'\WRSSI\W+(\-?\d+)', std)

        self.rssi = 0 if not _rssi else int(_rssi[0])

        self.noise = re.findall(r'WNoise\W+\-?\d+', std)
        self.noise = 0 if self.noise == [] else self.noise[0]
        self.date = dt.fromtimestamp(time.time())

    def __repr__(self) -> str:
        return f'<Poll RSSI={self.rssi}dBm Noise={self.noise} {self.date}>'


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

            last10 = polls[-10:]
            print(last10)
            print(
                f'{polls[-1]} | '
                f'Avg (last 10): {(sum(i.rssi for i in last10) )// len(last10)} | '
                f'Min:  {min(x.rssi for x in polls if x.rssi != 0)} | '
                f'Max: {min(x.rssi for x in polls if x.rssi != 0)}'
            )
        except BaseException as e:
            print(e)
        sleep(0.1)


if __name__ == '__main__':
    main()
