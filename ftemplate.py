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

    def __init__(self, outpath: str):
        self.fname = outpath.split('/')[-1]
        self.fext = '.' + self.fname.split('.')[-1]
        self.fstr = TEMPLATES[self.fext[1:]][0]

        self.tname = self.fname.split('.')[0]

        self.fpath = f'{abspath(os.curdir)}/{self.fname}'
        
        with open(self.fpath, 'w') as f:
            f.write(self.fstr)
            print(f'\nFile Template: {self.tname}')
            print(f'Current Directory Is: {os.getcwd()}')
            print(f'\n{LINE}\n{self.fstr}\n{LINE}\n')
            print(f'\n...written to {self.fpath}\n')

def main():
    fpath = str(sys.argv[1])

    ft = FTemp(outpath=fpath)

if __name__ == '__main__':
    main()



