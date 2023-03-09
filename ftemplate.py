#!/usr/bin/env python3
import sys
import os

from os.path import abspath
from typing import *

# FILE TEMPLATES STORED AS STRIPPED STRINGS TO PREVENT ANY ACCIDENTS
TEMP_PY3 = '''#!/usr/bin/env python3
def main():


if __name__ == '__main__':
    main()
'''.strip()

TEMPLATES = {
    'python3': (TEMP_PY3, '.py'),
    'python': TEMP_PY3,
}

SHORTHAND = {
    'py': 'python3',
    'py3': 'python3',
}

for s in SHORTHAND: # support short template names
    TEMPLATES[s] = TEMPLATES[SHORTHAND[s]]

LINE = 20 * '-'

class FTemp:
    fstr: Optional[str] = None
    fname: Optional[str] = None
    fpath: Optional[str] = None

    tname: Optional[str] = None

    def __init__(self, temp: str, outpath: str):
        self.tname = temp
        self.fstr = TEMPLATES[temp][0]

        if str(outpath)[0] == '/':
            self.fpath = outpath
            self.fname = str(str(outpath).split('/')[-1])
            self.fext = '.' + self.fname.split('.')[1]
        else:
            self.fext = TEMPLATES[temp][1]
            self.fname = f'{outpath}{self.fext}'
            self.fpath = f'{abspath(os.curdir)}/{self.fname}'
        
        with open(self.fpath, 'w') as f:
            f.write(self.fstr)
            print(f'\nFile Template: {temp}')
            print(f'Current Directory Is: {os.getcwd()}')
            print(f'\n{LINE}\n{self.fstr}\n{LINE}\n')
            print(f'\n...written to {self.fpath}')

def main():
    ftemp = str(sys.argv[1]).lower()
    fpath = str(sys.argv[2])

    ft = FTemp(ftemp, fpath)

if __name__ == '__main__':
    main()



