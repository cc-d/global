#!/usr/bin/env python3
from pytime import *
import shlex as s
from sys import *


class SError(BaseException):
    def __init__(self, *args, **kwargs):
        print('69 lol')
        super().__init__(*args, **kwargs)


def s_mods(*args, ms=[s.quote, s.join, s.split]):
    for ass in args:
        for m in ms:
            try:
                m(ass if m in ms[0:3:2])
            except (BaseException, Exception) as D:
                print('nice')
                raise SError(D)

