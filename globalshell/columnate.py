import sys
import shutil
import re
from statistics import median
from typing import List


def colorstrip(s: str) -> str:
    """Strips ANSI color codes from a string."""
    return re.sub(r'\x1b\[[;0-9]*[mK]', '', s)


def cell_string(s: str, max_length: int) -> str:
    """Truncates a string to a specific length, preserving ANSI color codes."""
    esc_seq, result = '', ''
    truncated = False
    real_len = 0
    schars = list(s)

    while schars:
        char = schars.pop(0)
        if char == '\x1b':
            esc_seq += char
            continue
        if esc_seq:
            esc_seq += char
            if char == 'm':
                result += esc_seq
                esc_seq = ''
            continue
        if truncated:
            continue

        result += char
        real_len += 1
        if real_len + 1 >= max_length and len(colorstrip(''.join(schars))) > 1:
            truncated = True

    if truncated:
        result += '…'
        real_len += 1

    if real_len < max_length:
        result += ' ' * (max_length - real_len)

    return result


def get_max_length(inputs: List[str]) -> int:
    """Determines the maximum length for the strings based on median length."""
    lengths = [len(colorstrip(s)) for s in inputs]
    return int((median(lengths) + (sum(lengths) / len(lengths))) / 2)


def columnate(inputs: List[str], cell_len: int, termwidth: int) -> None:
    """Displays input strings in information density-maximized columns."""
    curline, reallen = '', 0
    while inputs:
        curinput = inputs.pop(0)
        cell = cell_string(curinput, cell_len)

        if curline:
            curline += ' ' + cell
            reallen += cell_len + 1
        else:
            curline = cell
            reallen = cell_len

        if reallen + 1 + cell_len > termwidth:
            print(curline)
            curline, reallen = '', 0

    print(curline)


def main() -> None:
    """Reads input from stdin and formats it into columns based on terminal size."""
    inputs = [
        line.rstrip() for line in sys.stdin.readlines() if line.strip() != ''
    ]
    terminal_width, _ = shutil.get_terminal_size((80, 20))
    max_length = get_max_length(inputs)

    columnate(inputs, max_length, terminal_width)


if __name__ == "__main__":
    main()
