import subprocess
import timeit

def benchmark(cmd, runs=5):
    total_time = 0
    for _ in range(runs):
        start_time = timeit.default_timer()
        subprocess.run(cmd, shell=True)
        total_time += timeit.default_timer() - start_time
    return total_time / runs  # return average time

# Define the commands to run your scripts
python_cmd = "echo '{}' | python3 colorprint.py"
cpp_cmd = "echo '{}' | ./colorprint"

# Define the strings to test
strings = [
    'Hello, World!',
    '\033[31mHello, World!\033[0m',
    '\033[31mHello, \033[32mWorld!\033[0m',
    '\033[31mThis is a long string that will be split into multiple lines based on the terminal width.\033[0m',
    # Add more strings here
]

# Run the benchmarks
for s in strings:
    python_time = benchmark(python_cmd.format(s))
    cpp_time = benchmark(cpp_cmd.format(s))

    print(f"String: {s}")
    print(f"Average execution time for Python script: {python_time} seconds")
    print(f"Average execution time for C++ program: {cpp_time} seconds")
    print("\n")

