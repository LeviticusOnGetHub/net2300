# net2300 awk

**1. Who are the original creators of the AWK programming language?**

- A) Dennis Ritchie and Ken Thompson
- B) Alfred Aho, Peter Weinberger, and Brian Kernighan
- C) Linus Torvalds and Richard Stallman
- D) Guido van Rossum

**2. What is the primary purpose of AWK?**

- A) Compiling C++ applications
- B) Managing database hardware
- C) Pattern scanning and text processing
- D) Graphic design and image editing

**3. How does AWK process input data?**

- A) It reads the entire file into memory at once
- B) It reads input line by line
- C) It only processes the first 10 lines of any file
- D) It processes files in reverse order

**4. In AWK, what does the variable '$0' represent?**

- A) The first field of a line
- B) The last field of a line
- C) The entire current line
- D) The line number

**5. What is the correct basic syntax for an AWK command?**

- A) awk { action } 'pattern' file
- B) awk 'action { pattern }' file
- C) awk 'pattern { action }' file
- D) awk file (pattern) [action]

**6. Which special variable represents the current line number?**

- A) NF
- B) FS
- C) OFS
- D) NR

**7. What does the 'NF' variable stand for in AWK?**

- A) Next File
- B) Number of Fields in the current record
- C) New Format
- D) Null Field

**8. Which command would you use to print only the second and fourth columns of a file?**

- A) awk '{ print $2, $4 }' file
- B) awk '{ print 2, 4 }' file
- C) awk '{ display $2 $4 }' file
- D) awk '/2, 4/ { print }' file

**9. What is the default field separator in AWK?**

- A) Comma
- B) Semicolon
- C) Tab
- D) Space (Blank)

**10. How do you specify a custom field separator, such as a comma for CSV files?**

- A) Using the -S flag
- B) Using the -F flag
- C) Using the -X flag
- D) AWK cannot change separators

**11. When does the 'BEGIN' block execute?**

- A) After every line is processed
- B) Only if a pattern match is found
- C) Before any lines are processed
- D) At the end of the file

**12. When does the 'END' block execute?**

- A) Before the file is opened
- B) After all lines have been processed
- C) After the first line is read
- D) Only when an error occurs

**13. Which operator is used in AWK to match a field against a Regular Expression?**

- A) ==
- B) =
- C) ~
- D) !=

**14. What does the command 'awk "NR > 1 { print }" file' do?**

- A) Prints only the first line
- B) Prints the total number of lines
- C) Skips the first line (header) and prints the rest
- D) Prints only lines that have more than one field

**15. What is the purpose of the 'FS' variable?**

- A) To set the File Size
- B) To set the Input Field Separator
- C) To set the Final Summary
- D) To Format Strings

**16. Which variable is used to set the Output Field Separator?**

- A) ORS
- B) FS
- C) OFS
- D) RS

**17. How can you combine multiple conditions in a pattern?**

- A) Using 'AND' and 'OR' keywords
- B) Using '&&' for AND and '||' for OR
- C) Using '+' and '*' symbols
- D) Conditions cannot be combined

**18. In an AWK script file, what does '#!/bin/awk -f' at the top signify?**

- A) A comment describing the file
- B) The shebang line that tells the OS to use AWK to run the script
- C) A command to delete the file after execution
- D) A requirement to use a specific font

**19. What would 'awk "{ sum += $4 } END { print sum }"' calculate?**

- A) The average of the fourth column
- B) The total sum of values in the fourth column
- C) The number of rows in the file
- D) The maximum value in the fourth column

**20. What is 'ORS' in AWK?**

- A) Output Record Separator
- B) Original Record Score
- C) Open Read Stream
- D) Output Row Scanner

