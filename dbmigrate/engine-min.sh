#!/bin/bash
# engine-min.sh - minimal migrate engine.
# Every second: read 'pending' rows from the logs table, execute each command,
# set the row to 'done' or 'error', and log the result to stdout (redirect to dbmigrate.log).
#
# Usage:  nohup ./engine-min.sh >> dbmigrate.log 2>&1 &
#         ./engine-min.sh --once     process pending rows one time and exit
#
# Connection settings can be overridden with environment variables.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-logapp}"
DB_PASS="${DB_PASS:-logapp123}"
DB_NAME="${DB_NAME:-logdb}"
MYSQL_CONFIG="$(mktemp /tmp/engine-min.XXXXXX)"

# The mysql client is called mariadb on newer MariaDB installs
if command -v mysql >/dev/null 2>&1; then
    MYSQL_BIN=mysql
elif command -v mariadb >/dev/null 2>&1; then
    MYSQL_BIN=mariadb
else
    echo "mysql client not found. Install it with: sudo dnf install mariadb" >&2
    exit 1
fi

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*"
}

cleanup() {
    echo ""
    echo "Cleaning up..."
    rm -f "$MYSQL_CONFIG"
    exit 0
}
trap cleanup INT TERM EXIT

create_mysql_config() {
    cat > "$MYSQL_CONFIG" <<EOF
[client]
host=$DB_HOST
port=$DB_PORT
user=$DB_USER
password=$DB_PASS
database=$DB_NAME
# Newer clients require SSL by default; the local Docker server has none
skip-ssl
EOF
    # Secure the configuration file
    chmod 600 "$MYSQL_CONFIG"
}

update_status() {
    local log_id="$1" new_status="$2"
    "$MYSQL_BIN" --defaults-file="$MYSQL_CONFIG" -N -B \
        -e "UPDATE logs SET status = '$new_status' WHERE id = $log_id"
}

process_pending_logs() {
    # Keep each row's ID, command and status, its result, and logging variables local.
    # command_hex and output_hex hold SQL safe text, masked_command hides -p passwords.
    local id message status output rc command_hex output_hex masked_command

    # Read from fd 3 so executed commands cannot consume the pending list
    while IFS=$'\t' read -r -u 3 id message status; do
        # Send the original command to sed and save the new copy.
        # The pattern matches an attached, unquoted -p password after whitespace
        # or at the start the replacement preserves the -p prefix and masks it.
        # This does not mask other password formats
        masked_command=$(printf '%s' "$message" |
            sed -E 's/(^|[[:space:]])-p[^[:space:]]+/\1-p********/g')
        log "Processing ID: $id"
        # Print the masked copy, the original message is still used for execution.
        log "Command: $masked_command"

        update_status "$id" processing

        output=$(eval "$message" 2>&1 < /dev/null)
        rc=$?

        # Convert the masked command to hexadecimal bytes and remove od's spacing.
        # Encoding prevents quotes and newlines in the command from breaking SQL.
        command_hex=$(printf '%s' "$masked_command" | od -An -v -tx1 | tr -d ' \n')
        # Encode captured output the same way; it is not password-masked.
        output_hex=$(printf '%s' "$output" | od -An -v -tx1 | tr -d ' \n')

        # Execute an INSERT with the configured MySQL client.
        # UNHEX restores the command and output bytes; $id and $rc identify the
        # source entry and exit code. The table supplies the executed_at timestamp.
        # The if condition catches an unsuccessful database insert.
        if ! "$MYSQL_BIN" --defaults-file="$MYSQL_CONFIG" -e \
            "INSERT INTO execution_log (log_id, command, output, exit_code)
             VALUES ($id, UNHEX('$command_hex'), UNHEX('$output_hex'), $rc)"; then
            # Report the failure instead of claiming the execution was recorded.
            log "ERROR: Could not save execution log for ID $id"
        fi

        if [ "$rc" -eq 0 ]; then
            update_status "$id" done
            log "SUCCESS (exit 0) ID $id"
        else
            update_status "$id" error
            log "ERROR (exit $rc) ID $id"
        fi
        [ -n "$output" ] && log "Output: $output"
        log "---"
    done 3< <("$MYSQL_BIN" --defaults-file="$MYSQL_CONFIG" -N -B \
        -e "SELECT id, message, status FROM logs WHERE status = 'pending' ORDER BY id ASC")
}

create_mysql_config
log "Engine started (db=$DB_NAME host=$DB_HOST:$DB_PORT)"

if [ "$1" = "--once" ]; then
    process_pending_logs
    exit 0
fi

# Continuous loop
while true; do
    process_pending_logs
    # Wait 1 second before next iteration
    sleep 1
done
