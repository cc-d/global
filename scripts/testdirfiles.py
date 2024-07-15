#!/usr/bin/env python3
import argparse
import string
from pyshared import (
    ranstr,
    ran,
    op,
    os,
    sys,
    truncstr,
    get_terminal_width,
    print_columns,
)
from pathlib import Path


class DEFS:
    dirs = 10
    files = 50
    path = '/tmp'
    dirchar = 'D'
    filechar = 'F'
    dlen = 2
    flen = 4

    def rdir(pool=[]):
        def _s():
            return (
                DEFS.dirchar
                + ranstr(DEFS.dlen, chars=string.ascii_lowercase)
                + DEFS.dirchar
            )

        nd = _s()
        while nd in pool:
            nd = _s()
        return nd

    def rfile(pool=[]):
        def _s():
            return (
                DEFS.filechar
                + ranstr(DEFS.flen, chars=string.ascii_lowercase)
                + DEFS.filechar
            )

        nf = _s()
        while nf in pool:
            nf = _s()
        return nf


def recdirs(cd: Path, rem: int, cdirs: list = [], root=DEFS.path) -> list[str]:
    if rem <= 0:
        return cdirs

    cd = Path(cd) if isinstance(cd, str) else cd

    if ran.randint(0, 5) == 2 or cd.as_posix() == root:
        base = cd.as_posix()
    else:
        base = cd.parent.as_posix()

    newd = op.abspath(op.join(base, DEFS.rdir(pool=cdirs)))
    while newd in cdirs or op.abspath(newd) in cdirs or op.exists(newd):
        newd = op.abspath(op.join(base, DEFS.rdir(pool=cdirs)))

    os.makedirs(op.join(base, newd))
    cdirs.append(newd)

    rem -= 1

    return recdirs(newd, rem, cdirs)


def newfiles(rdirs: list[str], nfiles: int) -> list[str]:
    cd = rdirs[0]
    nf = []

    while nfiles > 0:
        cd = ran.choice(rdirs)
        fname = DEFS.rfile(pool=nf)
        fname = op.join(cd, fname)
        with open(fname, 'w') as f:
            f.write(ranstr(100))
            nfiles -= 1
            nf.append(fname)

    buf, i = '', 0
    twidth = get_terminal_width()
    (
        print_columns(nf)
        if max([len(x) for x in nf]) + 1 < twidth
        else [print(x) for x in nf]
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
