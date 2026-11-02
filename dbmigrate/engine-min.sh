#!/bin/bash

################################################################################
# Read and Execute Pending Logs from MariaDB Database
# 
# This script reads all log entries with status='pending' from the logs table,
# executes the message field as a command, and updates status accordingly
#
# Usage: ./engine-min.sh
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
# Function to update log status
################################################################################
update_log_status() {
    local log_id=$1
    local new_status=$2
 }

################################################################################
# Function to process pending logs
################################################################################
process_pending_logs() {
   echo "processing logs"
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