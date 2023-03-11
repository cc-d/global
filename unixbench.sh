#!/bin/bash

# CPU single-threaded performance test
echo "Running CPU single-threaded performance test..."
sysbench cpu --cpu-max-prime=20000 --threads=1 run 
echo "CPU single-threaded performance test complete."

# CPU multithreaded performance test
echo "Running CPU multithreaded performance test..."
sysbench cpu --cpu-max-prime=20000 --threads=$(nproc) run 
echo "CPU multithreaded performance test complete."

# Disk performance test
echo "Running disk performance test..."
sysbench fileio --file-total-size=1G prepare 
sysbench fileio --file-total-size=1G --file-test-mode=rndrw --time=10 --max-requests=0 run 
sysbench fileio --file-total-size=1G cleanup 
echo "Disk performance test complete."

# RAM performance test
echo "Running RAM performance test..."
total_mem=$(free -m | awk '/^Mem:/{print $2}')
mem_size=$((total_mem / 2))"M"
sysbench memory --memory-block-size=1K --memory-total-size=$mem_size run 
echo "RAM performance test complete."

# Network performance test
echo "Running network performance test..."
wget -O /dev/null https://speed.hetzner.de/100MB.bin
echo "Network performance test complete."

