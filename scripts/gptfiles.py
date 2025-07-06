#!/usr/bin/env python3
import argparse
import os.path as op
import platform as plat
import subprocess as subproc
import sys
from glob import glob
from pathlib import Path as P
from typing import Optional as Opt, Union as U

START = "<!-- FILE: {} -->\n"
END = "\n<!-- END: {} -->\n"


def copyclip(text: str):
    if plat.system() == "Darwin":
        subproc.run("pbcopy", text=True, input=text, shell=True)
    elif plat.system() == "Linux":
        subproc.run("xclip -selection clipboard", text=True, input=text, shell=True)


def read_file(fname):
    if not subproc.run(
        ["file", "--mime-type", "-b", fname], capture_output=True, text=True
    ).stdout.startswith("text/"):
        return ""
    with open(fname, "r", encoding="utf-8", errors="ignore") as f:
        lines = "\n".join(
            [
                l
                for l in f.read().splitlines()
                if l.strip() and not l.lstrip().startswith("#")
            ]
        )
        return START.format(fname) + lines + END.format(fname)


def main():
    parser = argparse.ArgumentParser(
        description="Wrap files or stdin with markers and copy to clipboard, using glob syntax"
    )
    parser.add_argument("paths", nargs="*")
    args = parser.parse_args()

    if args.paths:
        paths = args.paths
    else:
        if sys.stdin.isatty():
            print("No input", file=sys.stderr)
            sys.exit(1)
        paths = [p for p in sys.stdin]

    files = []
    for p in paths:
        if op.isfile(p):
            files.append(p)
        else:
            files.extend(glob(p, recursive=True))

    clip = "\n".join([read_file(f) for f in files if op.isfile(f)])

    copyclip(clip)

    print(f"{len(clip)} lines copied")


if __name__ == "__main__":
    main()
