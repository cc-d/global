#!/usr/bin/env python3
import argparse
import string
from pyshared import ranstr, ran, op, os, sys, truncstr
from pathlib import Path


class DEFS:
    dirs = 10
    files = 50
    path = '/tmp'
    dirchar = 'D'
    filechar = 'F'

    def rdir():
        return (
            DEFS.dirchar
            + ranstr(10, chars=string.ascii_lowercase)
            + DEFS.dirchar
        )

    def rfile():
        return (
            DEFS.filechar
            + ranstr(10, chars=string.ascii_lowercase)
            + DEFS.filechar
        )


_startpath = DEFS.path


def recdirs(cd: Path, rem: int, cdirs: list = [], root=DEFS.path) -> list[str]:
    if rem <= 0:
        print(
            'created',
            len(cdirs),
            'dirs',
            min(cdirs, key=lambda x: len(x)),
            '->',
            truncstr(max(cdirs, key=lambda x: len(x)), 50, end_chars=50),
        )
        return cdirs

    cd = Path(cd) if isinstance(cd, str) else cd

    if ran.randint(0, 5) == 2 or cd.as_posix() == _startpath:
        newdir = op.join(cd.as_posix(), DEFS.rdir())
    else:
        newdir = op.join(cd.parent.as_posix(), DEFS.rdir())

    os.makedirs(op.abspath(newdir))
    cdirs.append(newdir)

    rem -= 1

    return recdirs(newdir, rem, cdirs)


def newfiles(rdirs: list[str], nfiles: int) -> list[str]:
    cd = rdirs[0]
    nf = []

    while nfiles > 0:
        cd = ran.choice(rdirs)
        fname = DEFS.rfile()
        fname = op.join(cd, fname)
        with open(op.join(cd, fname), 'w') as f:

            f.write(ranstr(100))
            nfiles -= 1
            nf.append(fname)
    print(
        len(nf),
        'files created',
        min(nf, key=lambda x: len(x)),
        '->',
        truncstr(max(nf, key=lambda x: len(x)), 50, end_chars=50),
    )
    return nf


def main(ndirs: int = DEFS.dirs, nfiles: int = DEFS.files, path=DEFS.path):
    d = recdirs(path, ndirs, root=path)
    d.sort(key=lambda x: len(x))
    newfiles(d, nfiles)


def parse() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument(
        '-d',
        type=int,
        help='num dirs',
        default=DEFS.dirs,
        required=False,
        dest='dirs',
    )
    p.add_argument(
        '-f',
        type=int,
        help='num files',
        default=DEFS.files,
        required=False,
        dest='files',
    )
    p.add_argument(
        '-p',
        type=str,
        help='path to gen dirfiles in',
        default=DEFS.path,
        required=False,
        dest='path',
    )

    return p.parse_args()


if __name__ == '__main__':
    nspace = parse()
    main(nspace.dirs, nspace.files, nspace.path)
