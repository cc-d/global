#!/usr/bin/env python3

import platform
import re
import sys
import unittest
from typing import *
from os.path import expanduser


# use .zshrc by default if macos otherwise assume .bashrc
RCPATH = expanduser('~/.zshrc') if platform.system() == 'Darwin' else expanduser('~/.bashrc')

# used to detect various styles of setting evars
# LOL chatgpt ftw
EVAR_REG = r'''^.*?([A-Z_]+)=["']?([^"']+)["']?$'''

def is_upper_evar(line: str) -> Optional[Tuple[str, str]]:
    """if this line meets critiera for upper case bash env var
        assignment(ie: TEST=example), return the bash env var
        name as well as the env var value as an evar (name, value)

    Args:
        line (str): str usualyl single line from file

    Returns:
        Optional[Tuple[str, str]]: var name and val as strs if match or None
    """
    match = re.match(EVAR_REG, line)
    if match and len(match.groups()) == 2:
        return (match.group(1), match.group(2))
    return None

def update_evars(**kwargs) -> dict:
    """updates recognized evars like BNAME/TNAME etc in .zshrc or 
        .bashrc depending on the system type.

    Args:
        **kwargs: these are the environmental variables that will be updated

    Returns:
        dict representing updated evars
    """
    evars = {str(k).upper(): v for k, v in kwargs.items()} # cast kwargs to uppercase for evars
    updated_evars = [] # list of evar names

    if len(evars) != len(set(evars)): # means we had a duplicate throw error so no issues
        raise Exception(f'more than 1 environmental variable passed to updated_evars()')

    print(evars,'evarserverererererer')

    # compare to evars in file and update if needed
    with open(RCPATH, 'r+') as rcfile:
        rclines = rcfile.read().strip().splitlines()
        print('rclines after read', rclines)

        for rci in range(len(rclines)):
            rcline = rclines[rci]
            evline = is_upper_evar(rcline)

            if evline is not None and evline[0] in evars:
                print ('evif\n\n\n\n\n\nfngfgfhfghfghhfg')
                varname, varval = str(evline[0]).upper(), evline[1]

                if varname in evars and evars[varname] != varval:
                    newline = f'export {varname}="{evars[varname]}"'
                    updated_evars.append(varname)
                    print(f'\n\nupdated evar line: {rcline} to {newline}\n\n')
                    rclines[rci] = newline

    # newly added evar lines to file
    for kvar in evars:
        if kvar not in updated_evars:
            newline = f'\nexport {kvar}="{evars[kvar]}"\n'
            print(f'added new evar line to rc: {newline}')
            updated_evars.append(kvar)

    if len(updated_evars) > 0:
        print(f'@@@\n@@@\n@@@updating evars: {updated_evars} to rcfile at {RCPATH}')

        with open(RCPATH, 'w') as f:
            f.write('\n'.join([l for l in rclines]))

    return evars

def main():
    cmd = str(sys.argv[1]).lower().strip()

    if cmd == 'bname':
        reg = r"((^[a-zA-Z0-9]+-\d+)-?\S+$)"
        rmatch = re.match(reg, sys.argv[2])

        if rmatch and len(rmatch.groups()) == 2:
            BNAME, TNAME = rmatch.group(1), rmatch.group(2)
            print('evars', update_evars(BNAME=BNAME, TNAME=TNAME))
    elif cmd == 'gpath':


if __name__ == '__main__':
    main()
