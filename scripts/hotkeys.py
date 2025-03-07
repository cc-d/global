from pynput import keyboard
from pynput.keyboard import Controller, Listener
from typing import Iterable as Iter, Callable as Call
from random import choice

CON = Controller()


class Keybind:
    def __init__(self, out_text: str):
        self.out_text = out_text

    def type(self):
        press_keys(self.out_text)


KB_PAIRS = {
    '<ctrl>+<alt>+f': 'Full-Stack Engineer',
    '<ctrl>+<alt>+3': '365 Retail Markets',
}

KEYBINDS = {k: Keybind(v).type for k, v in KB_PAIRS.items()}


def press(key: str):
    CON.press(key)
    CON.release(key)


def press_keys(keys: Iter):
    for k in keys:
        press(k)


with keyboard.GlobalHotKeys(KEYBINDS) as gh:
    gh.join()
