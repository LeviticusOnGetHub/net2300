#!/bin/bash

################################################################################
# Read and Execute Pending Logs from MariaDB Database
# 
# This script reads all log entries with status='pending' from the logs table,
# executes the message field as a command, and updates status accordingly
#
# Usage: ./engine.sh
################################################################################

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MYSQL_CONFIG="$SCRIPT_DIR/.mysql.cnf"

# Database configuration
DB_HOST="127.0.0.1"
DB_PORT="3306"
DB_USER="root"
DB_PASS="rootpassword"
DB_NAME="logdb"

################################################################################
# Create MySQL configuration file
################################################################################
create_mysql_config() {
    cat > "$MYSQL_CONFIG" << EOF
[client]
host=$DB_HOST
port=$DB_PORT
user=$DB_USER
password=$DB_PASS
database=$DB_NAME
EOF
    
    # Secure the configuration file
    chmod 600 "$MYSQL_CONFIG"
}

################################################################################
# Function to escape strings for safe SQL insertion
################################################################################
sql_escape() {
    local s="$1"
    # Escape backslashes first, then single quotes
    s="${s//\\/\\\\}"
    s="${s//\'/\'\'}"
    printf "%s" "$s"
}

# Extract the database and destination path from a queued dump command.
get_export_details() {
    # Keep the queued shell command available for matching.
    local message="$1"
    # Match the dump tool, its database argument, and a quoted or unquoted redirect target.
    local export_regex="^[[:space:]]*(mysqldump|mariadb-dump)[[:space:]].*[[:space:]]([[:alnum:]_]+)[[:space:]]*>[[:space:]]*(\"[^\"]+\"|'[^']+'|[^[:space:]]+)[[:space:]]*$"

    # Clear previous results so a non-dump command cannot reuse stale values.
    EXPORT_DATABASE_NAME=""
    # Clear the destination path for the same reason.
    EXPORT_FILENAME=""

    # Populate the export metadata only when the full command matches.
    if [[ "$message" =~ $export_regex ]]; then
        # Capture group 2 is the database name.
        EXPORT_DATABASE_NAME="${BASH_REMATCH[2]}"
        # Capture group 3 is the redirected dump filename.
        EXPORT_FILENAME="${BASH_REMATCH[3]}"
        # Remove a leading double quote from a quoted filename.
        EXPORT_FILENAME="${EXPORT_FILENAME#\"}"
        # Remove a trailing double quote from a quoted filename.
        EXPORT_FILENAME="${EXPORT_FILENAME%\"}"
        # Remove a leading single quote from a quoted filename.
        EXPORT_FILENAME="${EXPORT_FILENAME#\'}"
        # Remove a trailing single quote from a quoted filename.
        EXPORT_FILENAME="${EXPORT_FILENAME%\'}"

        # Resolve relative filenames against the engine's working directory.
        if [[ "$EXPORT_FILENAME" != /* ]]; then
            # Store an absolute path so the import UI can find the dump later.
            EXPORT_FILENAME="$PWD/$EXPORT_FILENAME"
        fi
        # Report that a dump command was successfully recognized.
        return 0
    fi

    # Report that this queued command does not produce a recognized dump.
    return 1
}

################################################################################
# Insert an execution record
################################################################################
log_execution() {
    local log_id="$1"
    local cmd="$2"
    local status="$3"
    local exit_code="$4"
    local out="$5"
    echo "Logging execution for log_id: $log_id, status: $status"
    echo "Command: $cmd"
    # Limit size to avoid overly large rows (optional)
    local cmd_limited
    local out_limited
    cmd_limited=$(printf '%.4000s' "$cmd")
    out_limited=$(printf '%.20000s' "$out")

    # Escape for SQL
    local cmd_esc
    local out_esc
    cmd_esc=$(sql_escape "$cmd_limited")
    out_esc=$(sql_escape "$out_limited")
    # Insert the execution record into the database
}

################################################################################
# Insert an export log record
################################################################################
log_export() {
    # Accept the database name to store in export_log.
    local db_name="$1"
    # Accept the dump file path to store for later imports.
    local filename="$2"
    # Accept the export status (success or error).
    local status="$3"
    # Accept command output or an error explanation.
    local output="$4"
    # Accept the dump file size in bytes, when available.
    local file_size="$5"
    # Hold hex-encoded text and the validated SQL representation of file size.
    local db_name_hex filename_hex output_hex file_size_sql
    
    # Print a short progress message for the engine log.
    echo "Logging export for database: $db_name, file: $filename, status: $status"

    # Encode the database name as hex so quotes and other characters are SQL-safe.
    db_name_hex=$(printf '%s' "$db_name" | od -An -v -tx1 | tr -d ' \n')
    # Encode the filename the same way, preserving paths and spaces exactly.
    filename_hex=$(printf '%s' "$filename" | od -An -v -tx1 | tr -d ' \n')
    # Encode command output so it can safely be placed in the INSERT statement.
    output_hex=$(printf '%s' "$output" | od -An -v -tx1 | tr -d ' \n')

    # Only use a numeric file size in SQL to avoid inserting invalid values.
    if [[ "$file_size" =~ ^[0-9]+$ ]]; then
        # Preserve the measured byte count.
        file_size_sql="$file_size"
    else
        # Store SQL NULL when the file size could not be determined.
        file_size_sql="NULL"
    fi

    # Insert the export record and report failure to the caller if MySQL rejects it.
    if ! mysql --defaults-file="$MYSQL_CONFIG" -e \
        "INSERT INTO export_log (database_name, filename, status, output, file_size)
         VALUES (UNHEX('$db_name_hex'), UNHEX('$filename_hex'), '$status',
                 NULLIF(UNHEX('$output_hex'), ''), $file_size_sql)"; then
        # Send the failure to stderr so it is visible in the engine logs.
        echo "Error: could not record export for $db_name ($filename)" >&2
        # Let command processing mark the queued operation as failed.
        return 1
    fi
    # A successful INSERT completes this function with status 0.
}
################################################################################
# Function to update log status
################################################################################
update_log_status() {
    local log_id=$1
    local new_status=$2
    
    mysql --defaults-file="$MYSQL_CONFIG" -N -B \
        -e "UPDATE logs SET status = '$new_status' WHERE id = $log_id"
}

################################################################################
# Function to process pending logs
################################################################################
process_pending_logs() {
    # Get pending logs ordered by id ASC
    mysql --defaults-file="$MYSQL_CONFIG" -N -B \
        -e "SELECT id, message, status FROM logs WHERE status = 'pending' ORDER BY id ASC" | \
    while IFS=$'\t' read -r id message status; do
        # Track the detected database for this queue item, if it is a dump.
        local export_database=""
        # Track the dump path so it can be stored and imported later.
        local export_filename=""
        # Treat exports as failed until command and file checks prove success.
        local export_status="error"
        # Leave size empty until the destination file exists and can be measured.
        local export_size=""

        echo "Processing ID: $id"
        echo "Command: $message"
        echo "---"
        
        # Update status to 'processing'
        update_log_status "$id" "processing"
        
        # Identify dump metadata before running the queued command.
        get_export_details "$message"
        # Save the parsed database name for post-command logging.
        export_database="$EXPORT_DATABASE_NAME"
        # Save the parsed destination filename for validation and import logging.
        export_filename="$EXPORT_FILENAME"

        # Execute the command and capture output
        output=$(eval "$message" 2>&1)
        exit_code=$?

        # Add an export record only for recognized mysqldump/mariadb-dump commands.
        if [ -n "$export_database" ]; then
            # Measure the output file in bytes when the dump created it.
            if [ -f "$export_filename" ]; then
                export_size=$(wc -c < "$export_filename" | tr -d '[:space:]')
            fi

            # A zero exit code and nonempty dump are both required for success.
            if [ "$exit_code" -eq 0 ] && [ -s "$export_filename" ]; then
                # Mark the export importable by the frontend.
                export_status="success"
            # Convert a nominally successful but empty/missing dump into an error.
            elif [ "$exit_code" -eq 0 ]; then
                # Preserve any command output and append a useful file validation error.
                output="${output:+$output; }Dump command succeeded but the output file is missing or empty: $export_filename"
                # Propagate the failed dump through the existing queue status logic.
                exit_code=1
            fi

            # Persist the dump path and result so the frontend can offer an import.
            if ! log_export "$export_database" "$export_filename" "$export_status" "$output" "$export_size"; then
                # Include the database logging failure with any command output.
                output="${output:+$output; }Could not record this export in export_log"
                # Do not mark the queued operation done if its export record is missing.
                exit_code=1
            fi
        fi
        
        if [ $exit_code -eq 0 ]; then
            # Command succeeded - update status to 'done'
            update_log_status "$id" "done"
            echo "✓ Command completed successfully (ID: $id)"
            log_execution "$id" "$message" "done" "$exit_code" "$output"
            [ -n "$output" ] && echo "Output: $output"
        else
            # Command failed - update status to 'error'
            update_log_status "$id" "error"
            echo "✗ Command failed (ID: $id)"
            log_execution "$id" "$message" "done" "$exit_code" "$output"
            [ -n "$output" ] && echo "Error: $output"
        fi
        
        echo ""
    done
}

################################################################################
# Main execution
################################################################################

# Check if mysql client is installed
if ! command -v mysql &> /dev/null; then
    echo "Error: mysql client is not installed"
    echo "Install it with: brew install mysql (macOS) or sudo dnf install mysql (Rocky Linux)"
    exit 1
fi

# Create MySQL configuration file
create_mysql_config
echo "Starting continuous pending log processor..."
echo "Press Ctrl+C to stop"
echo "========================================"
echo ""

# Cleanup function to remove config file on exit
cleanup() {
    echo ""
    echo "Cleaning up..."
    rm -f "$MYSQL_CONFIG"
    exit 0
}

# Set trap to cleanup on exit
trap cleanup INT TERM EXIT

# Continuous loop
while true; do
    # Process pending logs
    process_pending_logs
    
    # Wait 1 second before next iteration
    sleep 1
done

exit 0