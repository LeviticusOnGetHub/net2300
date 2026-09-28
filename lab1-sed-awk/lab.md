## **UNIX Text Processing lab**

### **Lab Overview & Objectives**

This hands-on lab is structured into four difficulty tiers designed to build industry-grade text manipulation and log analysis skills

### Sample files:

[https://github.com/davidlislc/net2300/tree/develop/lab1-sed-awk](https://github.com/davidlislc/net2300/tree/develop/lab1-sed-awk)

access.log, ssd-config.mock

### Advanced Context & Extended Pattern Matching (Grep focus)

#### **Exercise 1.1: Multi-Line Context Tracking**

Find all unauthorized access attempts (HTTP Status 401 ) in access.log .

#### Exercise 1.2: Strict Address Extraction

Extract only the IPv4 addresses from access.log , printing each address on its own line.

### In-Place System Config Management & Rewriting: sed

Safely modify system configuration files in-place and restructure log strings using sed capture groups.

#### Exercise 2.1: Safe Configuration Update with Backup

Modify sshd_config.mock to change the commented port directive #Port 22 to an active port setting Port 2222 . Execute this edit in-place, while automatically generating a backup file named sshd_config.mock.bak .  
Hint: Provide an extension argument directly to the -i flag (e.g., -i.bak ).

#### Exercise 2.2: Deterministic Policy Enforcement

Enforce system security policy on sshd_config.mock : Find the line controlling PermitRootLogin (regardless of whether it is commented out or set to prohibit-password ), uncomment it, and set its value explicitly to no .  
Hint: Match optional leading comments ^#? and match through the entire line end.

#### Exercise 2.3: Comment & Blank Line Stripping

Print a clean, active view of sshd_config.mock to standard output by stripping out all comment lines (starting with # ) and all completely blank lines.  
Hint: Use address patterns with the delete command /pattern/d .

### Programmatic Data Aggregation & Pipelines (AWK FOCUS)

Extract numerical data, process records dynamically, and build stateful aggregations using awk .

#### Exercise 3.1: Bandwidth Accumulation

Calculate the total network payload (in bytes) transferred across all requests in access.log . The byte count is located in the final column (Field 10). Print the result inside an END block.  
Hint: Accumulate values into a dynamic variable: {total += $10} .

#### Exercise 3.2:: Structured Audit Formatting

Process sshd_config.mock using awk . Ignore all comments and blank lines. Print all active configuration options formatted strictly as: Directive: [Name] | Value: [Val] .  
Hint: Filter records where number of fields NF > 0 and record !/^#/ .

#### Exercise 3.3:  Parsing Double-Quoted Fields

Standard space-delimited awk breaks when fields contain spaces (like User-Agent strings). Parse access.log using double quotes as the field separator ( -F'"' ) to extract Field 6 (User-Agent) and count occurrences of each client tool.  
Hint: Set the quote separator with -F'"' . The User-Agent string becomes $6 and the Referrer becomes $4 .

#### Exercise 3.4: Incident Response Pipeline Challenge

Chain grep , sed , and awk together into a single pipeline to perform incident analysis on access.log :

1. Isolate all attempts targeting /login.php .
2. Extract the IP address and status code, mapping 401 to FAILED and 200 to SUCCESS .
3. Aggregate and print total FAILED attempts per offending IP address.

Hint: Pipe output between commands: grep | awk | sed | awk .
