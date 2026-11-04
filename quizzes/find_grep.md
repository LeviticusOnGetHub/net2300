# find_grep

**1. Which command is used to redirect output and overwrite an existing file?**

- A) >
- B) >>
- C) |
- D) &>

**2. What is the function of the '>>' operator?**

- A) Overwrites a file with new output
- B) Appends output to the end of a file
- C) Redirects error messages to a file
- D) Pipes output to another command

**3. How do you pipe the output of 'command A' into 'command B'?**

- A) command A > command B
- B) command A >> command B
- C) command A | command B
- D) command A &> command B

**4. What does '2> file' specifically redirect?**

- A) Standard output (stdout)
- B) Standard error (stderr)
- C) Both stdout and stderr
- D) Input from a file

**5. Which operator redirects both stdout and stderr to a single file?**

- A) 1>
- B) 2>
- C) |
- D) &>

**6. In shell scripting, what is a 'weak quote'?**

- A) Single quote (‘)
- B) Double quote (“)
- C) Back quote (`)
- D) Backslash (\)

**7. What happens to variables like $variable inside double quotes?**

- A) They are taken literally
- B) They are ignored
- C) They are replaced by their values
- D) They cause a syntax error

**8. Which quote type treats everything inside literally, with no special characters?**

- A) Double quote
- B) Single quote
- C) Back quote
- D) Pipe

**9. What is the purpose of the back quote (`) character?**

- A) To comment out a line
- B) To treat a string as a command and execute it
- C) To escape a special character
- D) To append text to a file

**10. What does the 'grep' acronym stand for?**

- A) General report evaluation program
- B) Global regular expression print
- C) Grouped regular entry point
- D) Global recursive element process

**11. What is the basic syntax for a grep command?**

- A) grep [file] [pattern]
- B) grep [options] pattern [file...]
- C) grep [pattern] > [file]
- D) grep -find [pattern]

**12. Which grep option allows you to search recursively through subdirectories?**

- A) -i
- B) -c
- C) -r
- D) -v

**13. To perform a case-insensitive search with grep, which option should be used?**

- A) -i
- B) -n
- C) -r
- D) -case

**14. How can you count the number of lines that match a pattern using grep?**

- A) grep -n
- B) grep -count
- C) grep -c
- D) grep -l

**15. What is the purpose of redirecting to '/dev/null'?**

- A) To save output for later
- B) To discard unwanted output or errors
- C) To create a new directory
- D) To speed up command execution

**16. Which command finds a file named 'Foo.txt' starting from the root directory?**

- A) find / -name "Foo.txt"
- B) grep "Foo.txt" /
- C) ls -r "Foo.txt"
- D) search / -name "Foo.txt"

**17. What does the '-iname' option do in the 'find' command?**

- A) Searches by inode number
- B) Searches by case-insensitive name
- C) Searches by internal name
- D) Searches for image files

**18. To find only directories using the 'find' command, which type flag is used?**

- A) -type f
- B) -type d
- C) -type dir
- D) -type l

**19. Which command restricts the 'find' results to the current directory only (no subdirectories)?**

- A) -depth 0
- B) -maxdepth 1
- C) -limit 1
- D) -level 1

**20. How do you find empty files in your home directory?**

- A) find ~ -type f -empty
- B) find ~ -size 0
- C) grep -empty ~
- D) ls -empty ~

**21. What does the '-exec' option in 'find' allow you to do?**

- A) Exclude files from the search
- B) Execute a command on each matched file
- C) Exit the search after the first match
- D) Export the list of files to a CSV

**22. In a 'find -exec' command, what does '{}' represent?**

- A) An empty file
- B) The end of the command
- C) A placeholder for the matched file
- D) A curly brace character

**23. What character is used to indicate the end of the '-exec' command sequence?**

- A) ;
- B) \;
- C) |
- D) &

**24. Which command finds all .tmp files and deletes them?**

- A) find . -name "*.tmp" -delete
- B) find . -name "*.tmp" -exec rm {} \;
- C) rm *.tmp | find
- D) grep -r ".tmp" | rm

**25. How do you find all .sh files and make them executable?**

- A) find . -name "*.sh" -exec chmod a+x {} \;
- B) chmod +x *.sh
- C) grep ".sh" | chmod a+x
- D) find . -type sh -run chmod

**26. Which command would search for the string 'Jane' inside all .txt files found by 'find'?**

- A) find . -name *txt | grep Jane
- B) find . -name *txt -exec grep Jane {} \;
- C) grep Jane *.txt
- D) find Jane -in *.txt

**27. What is the result of 'ls -l | wc -l'?**

- A) Lists all files and their sizes
- B) Counts the number of lines in the long listing output
- C) Creates a file named wc-l
- D) Deletes all files in the directory

**28. If you want to find only regular files (not directories), which flag do you use with 'find'?**

- A) -type f
- B) -type d
- C) -type file
- D) -type r

**29. Which command redirects stdout to a file (explicitly using the file descriptor for stdout)?**

- A) 0> file
- B) 1> file
- C) 2> file
- D) &> file

**30. Which of the following is a common use case for 'grep'?**

- A) Searching logs for error messages
- B) Filtering output of other commands
- C) Finding configuration settings
- D) All of the above

