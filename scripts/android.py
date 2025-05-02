#!/usr/bin/env python3
import subprocess
import sys
from time import sleep


def get_input_items():
    """Read items from stdin or prompt for input if stdin is a terminal"""
    if not sys.stdin.isatty():
        # Stdin is redirected from a file or pipe
        return [line.strip() for line in sys.stdin if line.strip()]
    else:
        # Stdin is a terminal, prompt for input
        print(
            "Enter items (one per line). Press Ctrl+D (Unix) or Ctrl+Z+Enter (Windows) when done:"
        )
        lines = []
        try:
            while True:
                line = input()
                if line.strip():
                    lines.append(line.strip())
        except EOFError:
            pass
        return lines


def main():
    # Need at least one argument for the command
    if len(sys.argv) < 2:
        print("Usage: python script.py command [arg1 arg2 ...]")
        print("Example: python script.py 'pm disable-user --user {0} {item}'")
        print("Items to act on are read from stdin.")
        sys.exit(1)

    # Get the command and arguments
    command = sys.argv[1]  # The base command to run
    args = sys.argv[2:]  # Additional arguments to replace {0}, {item}, etc.

    # Get items from stdin
    items = get_input_items()

    if not items:
        print("No items provided. Exiting.")
        sys.exit(1)

    # Process each item
    for item in items:
        # Replace {0}, {1}, etc. in the command with args
        formatted_command = command.format(*args, item=item)

        # Execute via adb shell
        full_command = f"adb shell {formatted_command}"
        print(f"Executing: {full_command}")
        subprocess.Popen(full_command.split())
        sleep(0.01)


if __name__ == "__main__":
    main()
