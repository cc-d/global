#!/usr/bin/env python3
import sys
import os

# FILE TEMPLATES STORED AS STRIPPED STRINGS TO PREVENT ANY ACCIDENTS
TEMP_PY3 = '''#!/usr/bin/env python3
def main():


if __name__ == '__main__':
    main()
'''.strip()

TEMPLATES = {
    'python3': TEMP_PY3,
    'python': TEMP_PY3,
    'py': TEMP_PY3,
    'py3': TEMP_PY3,
}

LINE = 20 * '-'

def main():
    ftemp = str(sys.argv[1]).lower()
    fpath = str(sys.argv[2])

    ptype = 'relative' if fpath[0] != '/' else 'absolute'

    ts = TEMPLATES[ftemp]

    print(f'\nFile Template: {ftemp}')
    print(f'Current Directory Is: {os.getcwd()}')
    print(f'Path Type: {ptype}')
    print(f'\n{LINE}\n{ts}\n{LINE}\n')
    print(f'\n...written to {fpath}')


if __name__ == '__main__':
    main()



