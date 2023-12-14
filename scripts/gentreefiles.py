import os
from os.path import join, dirname, abspath
import sys
import re
from typing import Tuple, Optional, List


def treere(line: str) -> Tuple[int, str]:
    """
    Generates depth and filename from a tree line.

    Args:
        line (str): A single line of the tree string.

    Returns:
        Tuple[int, str]: Depth of the tree structure and the name.
    """
    treg = re.match(r'(^[^\w]*)?(\w+.*)$', line)
    if len(treg.groups()) == 1:
        depth, name = 0, treg.group(1)
    else:
        depth, name = len(treg.group(1)), treg.group(2)
    return depth, name


def linetype(lname: str, ldepth: int, nextdepth: Optional[int] = None) -> str:
    """
    Determine the type (directory or file) of the current line.

    Args:
        lname (str): Name of the current line.
        ldepth (int): Depth of the current line.
        nextdepth (int, optional): Depth of the next line. Defaults to None.

    Returns:
        str: Returns 'dir' for directory, 'file' for file.
    """
    if lname.endswith('/'):
        return 'dir'
    else:
        if lname.startswith('.'):
            return 'file'
        elif re.search('^\w+\.\w+$', lname):
            return 'file'

    if nextdepth is not None:
        if nextdepth > ldepth:
            return 'dir'

    return 'file'


def create_tree(tree_string: str, base_path: str = os.getcwd()) -> List[str]:
    """
    Create directory and file structure based on the given tree string.

    Args:
        tree_string (str): The tree string.
        base_path (str): The base path to create the tree in.

    Returns:
        List[str]: List of paths that were created.
    """
    lines = tree_string.strip().splitlines()
    lines = [l.strip() for l in lines if l.strip() != '']

    nextline = None
    nextdepth = None
    newfiles = []
    lastrootname = None

    while len(lines) > 0:
        line = lines.pop(0)
        depth, name = treere(line)
        if len(lines) > 0:
            nextline = lines[0]
            nextdepth, nextname = treere(nextline)
        else:
            nextline = None
            nextdepth = None

        ltype = linetype(name, depth, nextdepth)

        if depth == 0:
            lpath = abspath(join(base_path, name))
            lastrootpath = lpath
        else:
            lpath = abspath(join(lastrootpath, name))

        print(f'Creating {ltype} at {lpath}')
        if ltype == 'dir':
            os.makedirs(lpath, exist_ok=True)
        else:
            if not os.path.exists(lpath):
                with open(lpath, 'w') as f:
                    f.write('')
            else:
                print('File already exists', lpath)
        newfiles.append(lpath)
    return newfiles


# Example usage
if __name__ == "__main__":
    created_paths = create_tree(sys.stdin.read())
