#!/bin/sh
set -eu

# Function to get the current time in seconds with nanoseconds
get_time() {
  python3 -c "from time import time; print(time())"
}

# Function to calculate the time difference
time_diff() {
  _tdiff=`echo "scale=20; $2 - $1" | bc`
  if [ "$_tdiff" = "0" ]; then echo "1"; else echo $_tdiff; fi
}

# Function to display system info
get_system_info() {
  echo "=== System Info ==="
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "OS: $NAME $VERSION_ID"
  elif command -v sw_vers >/dev/null 2>&1; then
    echo "OS: $(sw_vers -productName) $(sw_vers -productVersion)"
  else
    echo "OS: $(uname -s) $(uname -r)"
  fi
  if command -v sysctl >/dev/null 2>&1; then
    echo "CPU: $(sysctl -n machdep.cpu.brand_string 2>/dev/null || sysctl -n hw.model)"
    echo "Cores: $(sysctl -n hw.ncpu)"
    mem_size=$(sysctl -n hw.memsize)
    echo "Memory: $(echo "scale=2; $mem_size / (1024*1024*1024)" | bc) GB"
  elif [ -f /proc/cpuinfo ]; then
    echo "CPU: $(grep "model name" /proc/cpuinfo | head -1 | cut -d ':' -f 2 | xargs)"
    echo "Cores: $(grep -c "processor" /proc/cpuinfo)"
    mem_size=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
    echo "Memory: $(echo "scale=2; $mem_size / (1024*1024)" | bc) GB"
  fi
  echo
}

# Single-core CPU benchmark
run_single_core_cpu() {
  echo "=== Single-Core CPU Benchmark ==="
  t1=$(get_time)
  max=500
  i=2
  while [ $i -le $max ]; do
    is_prime=1
    j=2
    while [ $j -le $((i / 2)) ]; do
      if [ $((i % j)) -eq 0 ]; then
        is_prime=0
        break
      fi
      j=$((j + 1))
    done
    : "$is_prime"
    i=$((i + 1))
  done
  t2=$(get_time)
  echo "Prime calculation (single): $(time_diff $t1 $t2)s"
  echo
}

# Multi-core CPU benchmark
run_multi_core_cpu() {
  echo "=== Multi-Core CPU Benchmark ==="
  t1=$(get_time)
  if command -v sysctl >/dev/null 2>&1; then
    cores=$(sysctl -n hw.ncpu 2>/dev/null)
  elif [ -f /proc/cpuinfo ]; then
    cores=$(grep -c "processor" /proc/cpuinfo)
  else
    cores=4  # Default if we can't detect
  fi
  temp_script=$(mktemp)
  cat > "$temp_script" << 'EOF'
max=1500
i=2
while [ $i -le $max ]; do
  is_prime=1
  j=2
  while [ $j -le $((i / 2)) ]; do
    if [ $((i % j)) -eq 0 ]; then
      is_prime=0
      break
    fi
    j=$((j + 1))
  done
  : "$is_prime"
  i=$((i + 1))
done
EOF
  chmod +x "$temp_script"
  i=1
  while [ $i -le "$cores" ]; do
    "$temp_script" &
    i=$((i + 1))
  done
  wait
  t2=$(get_time)
  rm -f "$temp_script"
  echo "Prime calculation ($cores cores): $(time_diff $t1 $t2)s"
  echo
}

# Memory benchmark
run_memory() {
  echo "=== Memory Benchmark ==="
  t1=$(get_time)
  temp_file=$(mktemp)
  dd if=/dev/zero of="$temp_file" bs=1M count=100 2>/dev/null
  t2=$(get_time)
  write_time=$(time_diff $t1 $t2)
  write_speed=$(echo "scale=2; 100 / $write_time" | bc)
  echo "Write 100MB: ${write_time}s (${write_speed} MB/s)"
  
  t1=$(get_time)
  dd if="$temp_file" of=/dev/null bs=1M 2>/dev/null
  t2=$(get_time)
  read_time=$(time_diff $t1 $t2)
  read_speed=$(echo "scale=2; 100 / $read_time" | bc)
  echo "Read 100MB: ${read_time}s (${read_speed} MB/s)"
  
  rm -f "$temp_file"
  echo
}

# Disk benchmark
run_disk() {
  echo "=== Disk Benchmark ==="
  temp_dir=$(mktemp -d)
  t1=$(get_time)
  dd if=/dev/zero of="$temp_dir/test" bs=1M count=2000 2>/dev/null
  t2=$(get_time)
  write_time=$(time_diff $t1 $t2)
  write_speed=$(echo "scale=2; 500 / $write_time" | bc)
  echo "Write 500MB: ${write_time}s (${write_speed} MB/s)"
  
  if [ "$(id -u)" -eq 0 ]; then
    [ -f /proc/sys/vm/drop_caches ] && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
    command -v purge >/dev/null 2>&1 && purge 2>/dev/null || true
  fi
  
  t1=$(get_time)
  dd if="$temp_dir/test" of=/dev/null bs=1M 2>/dev/null
  t2=$(get_time)
  read_time=$(time_diff $t1 $t2)
  read_speed=$(echo "scale=2; 500 / $read_time" | bc)
  echo "Read 500MB: ${read_time}s (${read_speed} MB/s)"
  
  rm -f "$temp_dir/test"
  rmdir "$temp_dir"
  echo
}

# IOPS benchmark
run_iops() {
  echo "=== IOPS Benchmark ==="
  temp_dir=$(mktemp -d)
  t1=$(get_time)
  i=1
  while [ $i -le 1000 ]; do
    dd if=/dev/urandom of="$temp_dir/file_$i" bs=4K count=1 2>/dev/null
    i=$((i + 1))
  done
  t2=$(get_time)
  total_time=$(time_diff $t1 $t2)
  iops_rate=$(echo "scale=2; 1000 / $total_time" | bc)
  echo "Random 4K writes (1000 files): ${total_time}s (${iops_rate} IOPS)"
  
  t1=$(get_time)
  i=1
  while [ $i -le 1000 ]; do
    dd if="$temp_dir/file_$i" of=/dev/null bs=4K count=1 2>/dev/null
    i=$((i + 1))
  done
  t2=$(get_time)
  total_time=$(time_diff $t1 $t2)
  iops_rate=$(echo "scale=2; 1000 / $total_time" | bc)
  echo "Random 4K reads (1000 files): ${total_time}s (${iops_rate} IOPS)"
  
  rm -f "$temp_dir"/file_*
  rmdir "$temp_dir"
  echo
}

# Main execution
if [ $# -eq 0 ]; then
  get_system_info
  run_single_core_cpu
  run_multi_core_cpu
  run_memory
  run_disk
  run_iops
  echo "=== Benchmark Complete ==="
else
  get_system_info
  for arg in "$@"; do
    case "$arg" in
      -s|--single) run_single_core_cpu ;;
      -m|--multi) run_multi_core_cpu ;;
      -r|--ram) run_memory ;;
      -d|--disk) run_disk ;;
      -i|--iops) run_iops ;;
      -a|--all)
        run_single_core_cpu
        run_multi_core_cpu
        run_memory
        run_disk
        run_iops
        ;;
      *) echo "Unknown option: $arg" >&2 ;;
    esac
  done
  echo "=== Benchmark Complete ==="
fi

