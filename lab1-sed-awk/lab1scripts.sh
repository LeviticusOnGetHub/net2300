#!/bin/bash
echo "Running the lab scripts"

#### **Exercise 1.1: Multi-Line Context Tracking**

#Find all unauthorized access attempts (HTTP Status 401 ) in access.log .

echo "unauthorized access attempts found:"
# grep is looking for the 401 status code in access.log
grep '401' access.log

#### Exercise 1.2: Strict Address Extraction

# Extract only the IPv4 addresses from access.log , printing each address on its own line.

echo "IPv4 addresses found"
# grep is finding all ipv4 adresses by matching a pattern of 3 digits than a dot than 3 more digits repeated 3 times
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log

### In-Place System Config Management & Rewriting: sed

# Safely modify system configuration files in-place and restructure log strings using sed capture groups.

echo "Moding system config files with sed"
# sed  in place edits the old value to the new value in the config file
sed -i 's/old_value/new_value/' config_file.config

#### Exercise 2.1: Safe Configuration Update with Backup

# Modify sshd_config.mock to change the commented port directive #Port 22 to an active port setting Port 2222 . Execute this edit in-place, while automatically generating a backup file named sshd_config.mock.bak .  
# Hint: Provide an extension argument directly to the -i flag (e.g., -i.bak ).

echo "updating sshd_config.mock with a new port setting"
# sed in place edits the mock file and makes a new backup file with the .bak extension
sed -i.bak 's/^#Port 22/Port 2222/' sshd_config.mock

#### Exercise 2.2: Deterministic Policy Enforcement

# Enforce system security policy on sshd_config.mock : Find the line controlling PermitRootLogin (regardless of whether it is commented out or set to prohibit-password ), uncomment it, and set its value explicitly to no .  
# Hint: Match optional leading comments ^#? and match through the entire line end.
echo "enforcing permit root login policy"
# sed is finding whatever controls permit root login and replacing it to no
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' sshd_config.mock

#### Exercise 2.3: Comment & Blank Line Stripping

# Print a clean, active view of sshd_config.mock to standard output by stripping out all comment lines (starting with # ) and all completely blank lines.  
# Hint: Use address patterns with the delete command /pattern/d .

echo "stripping comments and blank lines from sshd_config.mock"
# sed removing all comment lines repusented by ^#.* and all blank lines ^$
# the i makes the matches case insensitive
sed 's/^#.*//i; /^$/d' sshd_config.mock

#### Exercise 3.1: Bandwidth Accumulation

# Calculate the total network payload (in bytes) transferred across all requests in access.log . The byte count is located in the final column (Field 10). Print the result inside an END block.  
# Hint: Accumulate values into a dynamic variable: {total += $10} .

echo "calculating network payload"
# awk is adding up the values in the 10th field to find the total payload
awk '{total += $10} END {print total}' access.log

#### Exercise 3.2:: Structured Audit Formatting

# Process sshd_config.mock using awk . Ignore all comments and blank lines. Print all active configuration options formatted strictly as: Directive: [Name] | Value: [Val] .  
# Hint: Filter records where number of fields NF > 0 and record !/^#/ .

echo "formatting sshd_config.mock"
# awk is filtering out blank lines and comments, then formatting the active directives
# NF makes sure the lines are not empty
# $0 !~ /^#/ ensures the line is not a comment
awk 'NF > 0 && $0 !~ /^#/ {print "directive: " $1 " | value: " $2}' sshd_config.mock

#### Exercise 3.3:  Parsing Double-Quoted Fields

# Standard space-delimited awk breaks when fields contain spaces (like User-Agent strings). Parse access.log using double quotes as the field separator ( -F'"' ) to extract Field 6 (User-Agent) and count occurrences of each client tool.  
# Hint: Set the quote separator with -F'"' . The User-Agent string becomes $6 and the Referrer becomes $4 .

echo " looking for user agents in access.log"
# awk using double quotes as the field separator to find User-Agent strings
# agents[$6]++ counts occurrences of each User-Agent string
# The END block looks over the collected agents and prints each agent with its count
awk -F'"' '{agents[$6]++} END {for (agent in agents) print agent, agents[agent]}' access.log

#### Exercise 3.4: Incident Response Pipeline Challenge

# Chain grep , sed , and awk together into a single pipeline to perform incident analysis on access.log :

# 1. Isolate all attempts targeting /login.php .
# 2. Extract the IP address and status code, mapping 401 to FAILED and 200 to SUCCESS .
# 3. Aggregate and print total FAILED attempts per offending IP address.

# Hint: Pipe output between commands: grep | awk | sed | awk .

echo "looking for failed logins"
# grep isolates lines with /login.php
# awk prints the IP address and status code
# sed maps 401 to FAILED and 200 to SUCCESS
# awk aggregates and prints total FAILED attempts per IP
# failed[$1]++ increments the count for the IP address if the status is FAILED
# The END block overlooks the failed array and prints the IPs with its count
grep "/login.php" access.log | awk '{print $1, $9}' | sed 's/ 401$/ FAILED/; s/ 200$/ SUCCESS/' | awk '$2=="FAILED" {failed[$1]++} END {for (ip in failed) print ip, failed[ip]}'
