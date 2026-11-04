#!/bin/bash

# Ensure script is run as root
# if not running as root, re-execute the script with sudo
if (( EUID != 0 )); then
    exec sudo -- bash "${BASH_SOURCE[0]}" "$@"
fi

# log file location
LOG_FILE="/var/log/system_monitor.log"

# starting system information logging function
# using log system function to capture all the system data
log_system_info() {
    {
        #print the date and make a little header so I can read
        echo "=================================================="
        echo " [SYSTEM STATUS REPORT] - $(date)"
        echo "=================================================="
        
        # print the memory usage
        echo ">> MEMORY USAGE:"
        # use free to make it legible and nr 1 and 2 for headers and memory info
        free -h | awk 'NR==1 || NR==2 {print "   " $0}'
        
        echo ""
        echo ">> UPTIME & LOAD:"
        # print the system uptime and load avg
        echo -n "   " && uptime
        
        echo ""
        echo ">> CPU USAGE:"
        # printing the cpu usage to show user system and idle %
        top -bn1 | grep "Cpu(s)" | awk '{print "   User: " $2 "%, System: " $4 "%, Idle: " $8 "%"}'
        
        echo ""
        echo ">> DISK USAGE as a percentage (%):"
        # printing the disk usage as a % for each mounted filesystem
        df -h --output=source,pcent,target | awk 'NR==1 || /^\/dev\// {print "   " $0}'
        
        echo "=================================================="
        echo ""
    } >> "$LOG_FILE"
}

log_system_info