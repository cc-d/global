import sys
import shutil
import re
from statistics import median
from typing import List


def real_length(s: str) -> int:
    """Calculates the real length of a string excluding ANSI color codes."""
    return len(re.sub(r'\x1b\[[;0-9]*[mK]', '', s))


def truncate_color_string(s: str, max_length: int) -> str:
    """Truncates a string to a specific length, preserving ANSI color codes."""
    esc_seq = ''
    result = ''
    real_len = 0

    for char in s:
        if char == '\x1b':
            esc_seq += char
            continue
        if esc_seq:
            esc_seq += char
            if char == 'm':
                result += esc_seq
                esc_seq = ''
            continue
        result += char
        real_len += 1
        if real_len > max_length - 2 and char != s[-1]:
            return result + '..'

    return result


def get_max_length(inputs: List[str]) -> int:
    """Determines the maximum length for the strings based on median length."""
    lengths = [real_length(s) for s in inputs]
    return int(median(lengths))


def columnate(inputs: List[str], max_length: int, num_columns: int) -> None:
    """Displays input strings in information density-maximized columns."""
    for i, line in enumerate(inputs):
        truncated = truncate_color_string(line, max_length)
        pad_length = (
            max_length
            + len(re.sub(r'\x1b\[[;0-9]*[mK]', '', truncated))
            - len(truncated)
        ) + 1
        print(
            truncated.ljust(pad_length),
            end=' ' if (i + 1) % num_columns else '\n',
        )

    print()


def main() -> None:
    """Reads input from stdin and formats it into columns based on terminal size."""
    inputs = [
        line.rstrip() for line in sys.stdin.readlines() if line.strip() != ''
    ]
    terminal_width, _ = shutil.get_terminal_size((80, 20))
    max_length = get_max_length(inputs)
    num_columns = max(1, terminal_width // (max_length + 2))

    columnate(inputs, max_length, num_columns)


if __name__ == "__main__":
    main()
