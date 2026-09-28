#!/bin/bash

# Find all 404 requests in apache_logs.txt with awk -> error.log

# exit when anything mucks up
set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# determine that were looking into apache logs and all its 10000 lines of goop
LOG_FILE="$SCRIPT_DIR/apache_logs.txt"
# throw all errors into a new file called error.log peaches and cream
ERROR_LOG="$SCRIPT_DIR/error.log"

# check if a log file is real before moving foward
if [[ ! -f "$LOG_FILE" ]]; then
# if not skadaddle and exit with the error message
    echo "Error: $LOG_FILE not found" >&2
    exit 1
fi

# look for the lines where the status code is 404 and document them in th error log 
awk '$9 == 404' "$LOG_FILE" > "$ERROR_LOG"

# tell who ever is running the script that it at least ran 
echo "404 entries written to $ERROR_LOG"