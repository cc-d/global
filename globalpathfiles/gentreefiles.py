import os
import sys
from typing import List, Optional


def create_tree(tree_string: str, base_path: str = ".") -> None:
    """
    Create directory and file structure based on the given tree string.
    """
    lines = tree_string.strip().splitlines()

    # Determine the indentation length
    indent_length = None
    for line in lines:
        if line.startswith(" "):
            stripped_line = line.lstrip()
            indent_length = len(line) - len(stripped_line)
            print(f"Indentation length determined as: {indent_length}")
            break

    path_stack: List[str] = []
    for line in lines:
        stripped_line = line.strip()
        if len(stripped_line) > 0 and stripped_line[0] in "├└│--| |-- ":
            stripped_line = stripped_line[1:].strip()

        if indent_length is not None:
            depth = (len(line) - len(stripped_line)) // indent_length
        else:
            depth = len(line) - len(stripped_line)

        # Pop to the correct parent directory or the base if necessary
        while len(path_stack) > depth:
            print(f"Popping from path stack: {path_stack.pop()}")

        # Get the current path
        cur_path = os.path.join(*path_stack, stripped_line)

        # cur_path = str(cur_path).replace(
        #    './' + str(os.path.abspath('.').split('/')[-1]), ''
        # )

        if indent_length is None:
            cur_path = cur_path.replace('-- ', '', -1).replace('|', '')
        print(f"Current path: {cur_path}")
        if stripped_line.endswith("/"):  # directory
            os.makedirs(cur_path, exist_ok=True)
            path_stack.append(stripped_line[:-1])
            print(f"Directory created: {cur_path}")
        else:  # file
            open(cur_path, 'w').close()
            print(f"File created: {cur_path}")


def test():
    tree_str = """
django-arm-test-runner/
|-- django_arm_test_runner/
|   |-- __init__.py
|   |-- runners.py
|-- tests/
|   |-- __init__.py
|   |-- test_runners.py
|-- setup.py
|-- README.md
|-- LICENSE
"""
    create_tree(tree_str)


# Example usage
if __name__ == "__main__":
    test()
