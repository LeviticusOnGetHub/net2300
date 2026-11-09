#!/bin/bash
# engine-min.sh - minimal migrate engine.
# Every second: read 'pending' rows from the logs table, execute each command,
# set the row to 'done' or 'error', and log the result to stdout (redirect to dbmigrate.log).
# mysqldump and mariadb-dump commands that redirect to a file are also recorded in export_log.
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

get_export_details() {
    local message="$1"
    local export_regex='^[[:space:]]*(mysqldump|mariadb-dump)[[:space:]].*[[:space:]]([[:alnum:]_]+)[[:space:]]*>[[:space:]]*([^[:space:]]+)[[:space:]]*$'

    EXPORT_DATABASE_NAME=""
    EXPORT_FILENAME=""

    if [[ "$message" =~ $export_regex ]]; then
        EXPORT_DATABASE_NAME="${BASH_REMATCH[2]}"
        EXPORT_FILENAME="${BASH_REMATCH[3]}"

        case "$EXPORT_FILENAME" in
            \"*\") EXPORT_FILENAME="${EXPORT_FILENAME#\"}"; EXPORT_FILENAME="${EXPORT_FILENAME%\"}" ;;
            \'*\') EXPORT_FILENAME="${EXPORT_FILENAME#\'}"; EXPORT_FILENAME="${EXPORT_FILENAME%\'}" ;;
        esac
    fi
}

record_export() {
    local database_name="$1" filename="$2" status="$3" output="$4" file_size="$5"
    local database_hex filename_hex output_hex file_size_sql

    database_hex=$(printf '%s' "$database_name" | od -An -v -tx1 | tr -d ' \n')
    filename_hex=$(printf '%s' "$filename" | od -An -v -tx1 | tr -d ' \n')
    output_hex=$(printf '%s' "$output" | od -An -v -tx1 | tr -d ' \n')

    if [[ "$file_size" =~ ^[0-9]+$ ]]; then
        file_size_sql="$file_size"
    else
        file_size_sql="NULL"
    fi

    if ! "$MYSQL_BIN" --defaults-file="$MYSQL_CONFIG" -e \
        "INSERT INTO export_log (database_name, filename, status, output, file_size)
         VALUES (UNHEX('$database_hex'), UNHEX('$filename_hex'), '$status',
                 NULLIF(UNHEX('$output_hex'), ''), $file_size_sql)"; then
        log "ERROR: Could not save export record for $database_name ($filename)"
        return 1
    fi

    log "Recorded export: database=$database_name file=$filename status=$status size=${file_size:-unknown}"
}

process_pending_logs() {
    # Keep each row's ID, command and status, its result, and logging variables local.
    # command_hex and output_hex hold SQL safe text, masked_command hides -p passwords.
    local id message status output rc command_hex output_hex masked_command
    local export_database export_filename export_status export_size

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

        get_export_details "$message"
        export_database="$EXPORT_DATABASE_NAME"
        export_filename="$EXPORT_FILENAME"

        output=$(eval "$message" 2>&1 < /dev/null)
        rc=$?

        if [[ -n "$export_database" ]]; then
            export_status="error"
            export_size=""

            if [[ -f "$export_filename" ]]; then
                export_size=$(wc -c < "$export_filename" | tr -d '[:space:]')
            fi

            if [[ "$rc" -eq 0 && -s "$export_filename" ]]; then
                export_status="success"
            elif [[ "$rc" -eq 0 ]]; then
                output="${output:+$output; }Dump command succeeded but the output file is missing or empty: $export_filename"
                rc=1
            fi

            if ! record_export "$export_database" "$export_filename" "$export_status" "$output" "$export_size"; then
                output="${output:+$output; }Could not record this export in export_log"
            fi
        fi

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
