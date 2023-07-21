import subprocess
import time
import platform
import random
import re

def benchmark(cmd):
    start_time = time.time()
    subprocess.run(cmd, shell=True)
    return time.time() - start_time

def truncate_string(string, max_lines=3, max_length=20):
    lines = re.split(r'\r?\n', string)[:max_lines]
    truncated_lines = []
    for line in lines:
        if len(line) > max_length:
            truncated_lines.append(line[:max_length] + '...')
        else:
            truncated_lines.append(line)
    return '\n'.join(truncated_lines)

# Determine the architecture
architecture = platform.machine()
colorprint_binary = "colorprint-arm" if architecture == "arm64" else "colorprint-x86"

# Define the command to run your colorprint script
python_cmd = "echo '{}' | python3 colorprint.py"
cpp_cmd = "echo '{}' | ./" + colorprint_binary

# Define the colors to choose from
colors = [
    '\033[31m',  # Red
    '\033[32m',  # Green
    '\033[33m',  # Yellow
    '\033[34m',  # Blue
    '\033[35m',  # Purple
    '\033[36m',  # Cyan
    '\033[37m',  # White
]

# Define the strings to test
strings = [
    'Hello, World!',
    'This is a test string.',
    'Lorem ipsum dolor sit amet.',
    'The quick brown fox jumps over the lazy dog.',
    'Colorful string with multiple colors: {}',
    'Another colorful string: {} {} {}',
    'Random colors: {} {} {} {}',
    'Long string with random colors: {}' * 100,
]

# Initialize variables for summary
total_python_time = 0
total_cpp_time = 0

# Initialize list for storing differences
differences = []

#...[truncated previous code for clarity]...

# Initialize dictionary for storing results
results = []

# Run the benchmarks
for i, s in enumerate(strings):
    # Choose random colors
    chosen_colors = random.choices(colors, k=s.count('{}'))

    # Format the string with chosen colors
    formatted_string = s.format(*chosen_colors)

    # Truncate the string if it exceeds the maximum lines and maximum length
    truncated_string = truncate_string(formatted_string)

    # Execute the Python script and measure the time
    python_time = benchmark(python_cmd.format(formatted_string))
    total_python_time += python_time

    # Execute the compiled binary and measure the time
    cpp_time = benchmark(cpp_cmd.format(formatted_string))
    total_cpp_time += cpp_time

    difference = abs(cpp_time - python_time)

    # Append to results
    results.append({
        "string": i + 1,
        "truncated_string": truncated_string,
        "python_time": python_time,
        "cpp_time": cpp_time,
        "difference": difference
    })

    print(f"String:\n{truncated_string}")
    print(f"Python script execution time: {python_time:.6f} seconds")
    print(f"Compiled binary execution time: {cpp_time:.6f} seconds")
    print("")


# Calculate average execution times
avg_python_time = total_python_time / len(strings)
avg_cpp_time = total_cpp_time / len(strings)

# Calculate overall difference
overall_difference = abs(avg_python_time - avg_cpp_time)

# Display summary
print("----- Summary -----")
print(f"{'Str.No':<8} {'Str (truncated)':<40} {'Py.Time':<10} {'Cpp.Time':<10} {'Diff.':<10}")
print('-'*80)
for result in results:
    print(f"{result['string']:<8} {result['truncated_string']:<40} {result['python_time']:.6f} {result['cpp_time']:.6f} {result['difference']:.6f}")

print('')
print(f"{'Avg.Py.Time':<10} {avg_python_time:.6f}")
print(f"{'Avg.Cpp.Time':<10} {avg_cpp_time:.6f}")
print(f"{'Overall Diff.':<10} {overall_difference:.6f}")

