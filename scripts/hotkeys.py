#!/usr/bin/env python
from pynput import keyboard
from pynput.keyboard import Controller, Listener
from typing import Iterable as Iter, Callable as Call
from random import choice

CON = Controller()


def keybind(out_text: str) -> Call:

    return lambda: press_keys(out_text)


MOD = '<ctrl>+<alt>+'

KB_PAIRS = {
    '1': 'Full-Stack Engineer',
    '3': '365 Retail Markets',
    'c': 'Cary Carter',
    'g': 'https://github.com/cc-d',
    'a': 'https://liberfy.ai',
    'l': 'https://linkedin.com/cary-carter',
}

KEYBINDS = {MOD + k: keybind(v) for k, v in KB_PAIRS.items()}

for kb in KEYBINDS:
    print(kb, KB_PAIRS[kb.replace(MOD, '')])

def press(key: str):
    CON.press(key)
    CON.release(key)


def press_keys(keys: Iter):
    press(keyboard.Key.backspace)
    for k in keys:
        press(k)


with keyboard.GlobalHotKeys(KEYBINDS) as gh:
    gh.join()
