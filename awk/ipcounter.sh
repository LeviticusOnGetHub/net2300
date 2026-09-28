#!/bin/bash
#

# exit when anything sneaks up and goes wrong
set -euo pipefail

# declare
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# determine that were looking into apache logs and all its 10000 lines of goop again 
LOG_FILE="$SCRIPT_DIR/apache_logs.txt"
# declare where to put the ip log count in a new file
IP_LOG="$SCRIPT_DIR/ip.log"

# check if the log file exists before going through with the census
if [[ ! -f "$LOG_FILE" ]]; then
# if not scram and and flash the error message
    echo "Error: $LOG_FILE not found" >&2
    exit 1
fi

# awk = look for count[$1]++ = count the occurrences of each IP address (field $1)
awk '{ count[$1]++ } END { for (ip in count) print count[ip], ip }' "$LOG_FILE" \
# sort the count in decending order and ship it off
    | sort -rn > "$IP_LOG"

# tell the user that it went through 
echo "IP request counts written to $IP_LOG"
