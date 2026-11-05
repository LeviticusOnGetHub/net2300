#!/bin/bash
# dblogrotate.sh - rotate dbmigrate.log by date.
# The engine keeps dbmigrate.log open (nohup ... >> dbmigrate.log), so the log is
# copied to the archive and then truncated in place instead of being moved.
#
# Usage:
#   ./dblogrotate.sh                 rotate now
#   ./dblogrotate.sh --install-cron  schedule a daily run at midnight

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LOG_FILE="${LOG_FILE:-$SCRIPT_DIR/dbmigrate.log}"
ARCHIVE_DIR="${ARCHIVE_DIR:-$SCRIPT_DIR/archive}"
DATE=$(date +%Y-%m-%d)
ROTATED_LOG="${ARCHIVE_DIR}/dbmigrate-${DATE}.log"

# Install a daily midnight cron job (idempotent)
if [ "$1" = "--install-cron" ]; then
    SCRIPT_PATH="$(readlink -f "$0")"
    CRON_LINE="0 0 * * * ${SCRIPT_PATH}"
    ( crontab -l 2>/dev/null | grep -vF "$SCRIPT_PATH"; echo "$CRON_LINE" ) | crontab -
    echo "Installed: $CRON_LINE"
    exit 0
fi

# Ensure archive directory exists
mkdir -p "$ARCHIVE_DIR"

# Rotate the log: archive a copy, then empty the live file
if [ -f "$LOG_FILE" ]; then
    # Append so a second run on the same day does not overwrite the first archive
    cat "$LOG_FILE" >> "$ROTATED_LOG"
    : > "$LOG_FILE"
    chmod 644 "$LOG_FILE"
    echo "Rotated $LOG_FILE -> $ROTATED_LOG"
else
    echo "No log file at $LOG_FILE, nothing to rotate"
fi
