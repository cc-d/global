#!/usr/bin/env python3
import os
from random import randint as ri
from multiprocessing import Pool

def cpu_warmup(_):
    while True:
        r1, r2 = ri(1, 100000000), ri(1, 100000000)
        print(''.join((i for i in str(r1 * r2))))

if __name__ == "__main__":
    num_cores = os.cpu_count()
    num_processes = num_cores - 1 if num_cores > 1 else 1

    print(f"Number of CPU cores: {num_cores}")
    print(f"Spawning {num_processes} processes to warm up CPU cores.")

    with Pool(processes=num_processes) as pool:
        pool.map(cpu_warmup, [None] * num_processes)
