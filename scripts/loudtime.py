#!/usr/bin/env python
import random
import os
import re
import subprocess
from datetime import datetime as dt
from time import strftime, sleep, time
from typing import Tuple as T
from sys import argv

ONES = [
    "zero",
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
]


# Map numbers to words for minutes/seconds (00–59)
def two_word(num: int) -> str:

    teens = [
        "ten",
        "eleven",
        "twelve",
        "thirteen",
        "fourteen",
        "fifteen",
        "sixteen",
        "seventeen",
        "eighteen",
        "nineteen",
    ]
    tens = ["", "", "twenty", "thirty", "forty", "fifty"]
    n = int(num)
    if n < 10:
        return f"{ONES[n]}"
    elif 10 <= n < 20:
        return teens[n - 10]
    else:
        t, o = divmod(n, 10)
        return f"{tens[t]} {ONES[o]}" if o else tens[t]


# Speak time naturally with espeak in non-blocking manner
def speak(speak: str, is_time: bool = True, *args) -> None:
    if is_time is False:
        # Run espeak non-blocking
        subprocess.Popen(
            ['espeak', speak, *args],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        return

    h, m, s = speak.split(':')
    # Remove leading 0 from hour for natural speech

    hour_word = (
        'twelve'
        if h == '00'
        else ONES[int(h[1])] if h[0] == '0' else two_word(h)
    )
    minute_word = two_word(m)
    second_word = two_word(s)
    spoken = ' '.join((hour_word, minute_word, second_word))
    print(spoken)
    # Run espeak non-blocking
    subprocess.Popen(
        ['espeak', spoken],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def get_time() -> T[int, str]:
    t = time()
    return t, dt.fromtimestamp(t).isoformat().split('T')[1].split('.')[0]


def main():

    speak_every = 1 if len(argv) <= 1 else int(argv[1])
    prevtime = None
    while True:
        cur = get_time()
        if prevtime is not None:
            tdiff = int(cur[0]) - int(prevtime)
            if tdiff != speak_every:
                warn = 'TIME CHANGED IN INCREMENT > 1 SECOND'
                speak(warn)
                print(warn)
        sleep(speak_every)

        speak(cur[1], argv[2:])
        prevtime = cur[0]
        print(cur[1])


if __name__ == '__main__':
    main()
