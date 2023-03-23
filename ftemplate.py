#!/usr/bin/env python3
import sys
from os.path import abspath, isfile, expanduser
from typing import *



# FILE TEMPLATES STORED AS STRIPPED STRINGS TO PREVENT ANY ACCIDENTS
TEMP_PY3 = '''
#!/usr/bin/env python3


def main():


if __name__ == '__main__':
    main()
'''.strip() + '\n'

TEMPLATES = {
    'python3': (TEMP_PY3, '.py'),
    'python': TEMP_PY3,
}

EXT = {
    'py': 'python3',
    'py3': 'python3',
}

for s in EXT: # support short template names
    TEMPLATES[s] = TEMPLATES[EXT[s]]

LINE = 20 * '-'

class FTemp:
    fstr: str
    fname: str
    fpath: str

    tname: str

    def __init__(self, outpath: str):
        if isfile(outpath):
            raise Exception('file already exists error')

        self.fpath = expanduser(str(outpath))
        self.fext = str(self.fpath.split('.')[-1]).lower()
        self.fstr = TEMPLATES[self.fext][0]

        self.tname = '.'.join(self.fpath.split('/')[-1].split('.')[:-1])

        with open(self.fpath, 'w') as f:
            f.write(self.fstr)
            print(f'\n{LINE}\n{self.fstr}\n{LINE}\n')
            print(f'\n...written to {self.fpath}\n')

def main():
    fpath = str(sys.argv[1])

    ft = FTemp(outpath=fpath)

if __name__ == '__main__':
    main()



