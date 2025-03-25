from hashlib import sha512
from string import ascii_letters, digits


_EX = {'i', 'I', '1', 'o', '0', 'O', }
_ASCII = [c for c in ascii_letters + digits + '@~%^&*()-_+=[]|:;<>/?' if c not in _EX]

def _rs(n: int = 20):
    return



def key():
    return ranstr(