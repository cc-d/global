import time
import asyncio
import threading
import multiprocessing
import random
import math

REPS = 10  # Reduced repetitions for simplicity

# CPU-bound
def factorial(n):
    return [math.factorial(50) for _ in range(REPS)]

async def async_factorial(n):
    return factorial(n)

# I/O-bound
def io_bound(n):
    time.sleep(0.001)

async def async_io_bound(n):
    await asyncio.sleep(0.001)

# Matrix Multiplication
def matrix_multiplication(n):
    X = [[1, 2], [4, 5]]
    Y = [[7, 8], [9, 10]]
    result = [[0, 0], [0, 0]]
    for _ in range(REPS):
        for i in range(len(X)):
            for j in range(len(Y[0])):
                for k in range(len(Y)):
                    result[i][j] += X[i][k] * Y[k][j]

async def async_matrix_multiplication(*args):
    return matrix_multiplication(*args)

# [Continue with other benchmark functions if needed]

def benchmark(task, mode="thread"):
    start_time = time.time()

    if mode == "thread":
        threads = [threading.Thread(target=task, args=(i,)) for i in range(REPS)]
        [t.start() for t in threads]
        [t.join() for t in threads]

    elif mode == "process":
        with multiprocessing.Pool() as pool:
            pool.map(task, range(REPS))

    elif mode == "async":
        loop = asyncio.get_event_loop()
        loop.run_until_complete(asyncio.gather(*(task(i) for i in range(REPS))))

    elapsed_time = time.time() - start_time
    return elapsed_time

def main():
    tasks = [factorial, io_bound, matrix_multiplication, ]  # ... [Add all functions]
    tasks_async = [async_factorial, async_io_bound, async_matrix_multiplication, ]  # ... [Add all functions
    tasks_map = {
        factorial: async_factorial,
        io_bound: async_io_bound,
        matrix_multiplication: async_matrix_multiplication,
    }

    for task, atask in tasks_map.items():
        print(f"Benchmarking {task.__name__}")
        print(f"Async: {benchmark(atask, 'async'):.4f} seconds")
        print(f"Thread: {benchmark(task, 'thread'):.4f} seconds")
        print(f"Process: {benchmark(task, 'process'):.4f} seconds")
        print("\n")

if __name__ == "__main__":
    main()
