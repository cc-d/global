#!/bin/bash

# Display CPU information
echo -e "\033[1;34m===== CPU Information =====\033[0m"
lscpu | grep "Architecture\|Model name"

# Display GPU information
echo -e "\033[1;34m===== GPU Information =====\033[0m"
lspci | grep -i --color 'vga\|3d\|2d'
echo "Detailed GPU information:"
lspci -v -s $(lspci | grep -i 'vga\|3d\|2d' | awk '{print $1}')

# Display RAM information
echo -e "\033[1;34m===== RAM Information =====\033[0m"
free -h
echo "RAM Slots and Module Information:"
sudo dmidecode --type 17 | grep -i --color "Size\|Locator\|Bank Locator\|Speed\|Manufacturer\|Configured Memory Speed\|Module Manufacturer ID\|Memory Subsystem Controller Manufacturer ID\|Non-Volatile Size\|Volatile Size\|Cache Size\|Logical Size"

# RAM used and available
ram_used=$(free -h | grep "Mem:" | awk '{print $3}')
ram_available=$(free -h | grep "Mem:" | awk '{print $7}')

# Display storage information
echo -e "\033[1;34m===== Storage Information =====\033[0m"
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,MODEL
df -h --total

# Display operating system information
echo -e "\033[1;34m===== Operating System Information =====\033[0m"
lsb_release -a

# Display summary
echo -e "\033[1;34m===== Summary =====\033[0m"
cpu_model=$(lscpu | grep "Model name" | awk -F: '{print $2}' | xargs)
gpu_model=$(lspci | grep -i 'vga\|3d\|2d' | awk -F: '{print $3}' | xargs)
total_ram=$(free -h | grep "Mem:" | awk '{print $2}')
os_info=$(lsb_release -d | awk -F: '{print $2}' | xargs)
disk_space=$(df -h --total | grep "total" | awk '{print "Used: " $3 " / Available: " $4}')

echo -e "CPU: \033[1;32m$cpu_model\033[0m"
echo -e "GPU: \033[1;32m$gpu_model\033[0m"
echo -e "RAM: \033[1;32m$total_ram\033[0m"
echo -e "OS: \033[1;32m$os_info\033[0m"
echo -e "Disk Space: \033[1;32m$disk_space\033[0m"

