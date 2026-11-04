# net2300 Shell Script 2

**1. Which of the following is NOT a valid syntax for a test expression in shell scripting?**

- A) test EXPRESSION
- B) [ EXPRESSION ]
- C) [[ EXPRESSION ]]
- D) { EXPRESSION }

**2. Why is the '[[ ... ]]' syntax often preferred over '[ ... ]' in new scripts?**

- A) It is faster to execute
- B) It has more features like wildcards and regex
- C) It uses less memory
- D) It is the only one that supports numeric comparison

**3. What is a critical requirement when using the '[ EXPRESSION ]' syntax?**

- A) There must be a space after [ and before ]
- B) The expression must be in all caps
- C) It must be followed by a semicolon
- D) Variables cannot be used inside it

**4. Which string test operator is used to check if a string is null (zero length)?**

- A) -n
- B) -z
- C) -e
- D) -f

**5. Which operator is used to test if two integers are NOT equal?**

- A) -eq
- B) -gt
- C) -ne
- D) -lt

**6. In numeric comparison, what does the '-ge' operator represent?**

- A) Greater than
- B) Less than or equal
- C) Greater than or equal
- D) Equal to

**7. Which file enquiry operation is used to test if a file exists?**

- A) -f
- B) -d
- C) -e
- D) -x

**8. How do you test if a file is a directory?**

- A) -f file
- B) -d file
- C) -s file
- D) -r file

**9. Which positional parameter variable contains the name of the script being executed?**

- A) $1
- B) $#
- C) $0
- D) $*

**10. What does the '$#' variable represent in a shell script?**

- A) The process ID of the shell
- B) The number of command line parameters
- C) The exit code of the last command
- D) All parameters as a list

**11. Which variable captures the exit code (return code) of the last executed command?**

- A) $$
- B) $@
- C) $?
- D) $*

**12. What is the correct syntax for arithmetic expansion in Bash?**

- A) $[ expression ]
- B) $(( expression ))
- C) $( expression )
- D) { expression }

**13. Which arithmetic operator is used to find the remainder of a division (modulus)?**

- A) /
- B) *
- C) %
- D) -

**14. Which loop type is best used for iterating over a known list of items or ranges?**

- A) while loop
- B) until loop
- C) for loop
- D) if loop

**15. A 'while' loop continues to run as long as the condition is:**

- A) True
- B) False
- C) Null
- D) Zero

**16. Which statement is used to exit a loop immediately?**

- A) continue
- B) break
- C) exit
- D) stop

**17. What does the 'continue' statement do in a loop?**

- A) Exits the entire script
- B) Restarts the loop from the beginning
- C) Skips the rest of the current iteration
- D) Pauses the loop

**18. Which syntax represents a C-style for loop in Bash?**

- A) for i in list
- B) for ((i=0; i<5; i++))
- C) for i from 1 to 5
- D) foreach i in list

**19. How can you loop through all files with a '.log' extension?**

- A) for file in .log
- B) for file in *.log
- C) while [ *.log ]
- D) until [ *.log ]

**20. What is the recommended practice for variables used in test expressions?**

- A) Leave them unquoted
- B) Use single quotes
- C) Use double quotes
- D) Use curly braces

