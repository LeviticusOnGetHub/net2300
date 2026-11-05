#!/bin/bash
# Rotates /var/log/myapp.log into /var/log/archive/ with a date stamp.
# Usage:
#   sudo ./LOG_ROTATION.sh                 rotate now
#   sudo ./LOG_ROTATION.sh --install-cron  schedule a daily run at midnight

# Set paths
LOG_FILE="/var/log/myapp.log"
ARCHIVE_DIR="/var/log/archive"
DATE=$(date +%Y-%m-%d)
ROTATED_LOG="${ARCHIVE_DIR}/myapp-${DATE}.log"

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

# Rotate the log
if [ -f "$LOG_FILE" ]; then
    mv "$LOG_FILE" "$ROTATED_LOG"
    touch "$LOG_FILE"
    chmod 644 "$LOG_FILE"
fi