#!/usr/bin/env python3
import os
import shutil
import re
import sys

# ANSI escape sequences: color code start with '\033[' and end with 'm'
COLOR_CODES = re.compile(r'\x1b\[[0-9;]*m')

def wrap_text(text, width):
    lines = []
    line = ''
    length = 0
    for word in text.split(' '):
        # Calculate word length without color codes
        word_length = len(COLOR_CODES.sub('', word))
        # If adding the word won't exceed the width, add the word to the line
        if length + word_length <= width:
            line += word + ' '
            length += word_length + 1
        # Otherwise, add the line to the lines and start a new line
        else:
            lines.append(line)
            line = word + ' '
            length = word_length + 1
    # Add the last line to the lines
    lines.append(line)
    return lines

def color_print(color_string):
    # Calculate terminal width
    maxlen = shutil.get_terminal_size().columns
    words = color_string.split()
    curline = ''
    curlen = 0

    while words != []:
        word = words.pop(0)
        if str(word).endswith(','):
            word = str(word)[:-1]

        word += ' '
        ncword = re.sub(COLOR_CODES, '', word)
        nclen = len(ncword)

        if curlen + nclen >= maxlen:
            print(curline)
            curline = word
            curlen = nclen
        else:
            curline += word
            curlen += nclen

    print(curline)


# Example usage
if sys.stdin.isatty():
    color_string = '\033[31mHello, World! This is a long string that will be split into multiple lines based on the terminal width.\033[0m'
    color_print(color_string)
else:
    color_print(sys.stdin.read().strip())

