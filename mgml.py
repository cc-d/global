#!/usr/bin/env python3

import sys
import doctest


def calculate_mg_per_ml(mg: float, ml: float) -> None:
    """
    Calculate milligrams per 0.1 milliliters (ml) based on input values.

    Args:
        mg (float): The number of milligrams.
        ml (float): The number of milliliters.
    """
    try:
        mg_per_ml = mg / ml
        mg_per_tenth_ml = mg_per_ml * 0.1

        print(f"{mg} mg per {ml} ml is equivalent to {mg_per_tenth_ml} mg per 0.1 ml.")

    except ZeroDivisionError:
        print("Invalid input. Division by zero is not allowed.")
    except ValueError:
        print("Invalid input. Please enter numeric values.")


def run_tests() -> None:
    """
    Run doctests to verify the correctness of the program.
    """
    tests = """
    >>> calculate_mg_per_ml(100, 20)
    100 mg per 20 ml is equivalent to 5.0 mg per 0.1 ml.

    >>> calculate_mg_per_ml(50, 10)
    50 mg per 10 ml is equivalent to 5.0 mg per 0.1 ml.

    >>> calculate_mg_per_ml(75, 15)
    75 mg per 15 ml is equivalent to 5.0 mg per 0.1 ml.

    >>> calculate_mg_per_ml(0, 100)
    0 mg per 100 ml is equivalent to 0.0 mg per 0.1 ml.

    >>> calculate_mg_per_ml(100, 0)
    Invalid input. Division by zero is not allowed.

    >>> calculate_mg_per_ml('abc', 10)
    Invalid input. Please enter numeric values.
    """

    result = doctest.testmod()
    if result.failed == 0:
        print("All tests passed!")
    else:
        print(f"{result.failed} test(s) failed.")


# Check if the program is run with the correct number of command-line arguments
if len(sys.argv) == 2 and sys.argv[1] == "tests":
    run_tests()
elif len(sys.argv) == 3:
    # Extract the command-line arguments
    mg_input = sys.argv[1]
    ml_input = sys.argv[2]

    try:
        mg_value = float(mg_input[:-2])
        ml_value = float(ml_input[:-2])
        mg_unit = mg_input[-2:]
        ml_unit = ml_input[-2:]

        if mg_unit == 'mg' and ml_unit == 'ml':
            calculate_mg_per_ml(mg_value, ml_value)
        else:
            print("Invalid input. Please enter values in the correct units (mg and ml).")

    except ValueError:
        print("Invalid input. Please enter numeric values.")
else:
    print("Usage: ./mgml.py [mg] [ml]")
    print("Usage: ./mgml.py tests")

