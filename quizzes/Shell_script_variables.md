# Shell script variables

**1. Which of the following describes shell variables?**

- A) Hardcoded values that cannot be changed
- B) Symbolic names that can access values stored in memory
- C) Commands used to compile shell scripts
- D) Hardware addresses for input devices

**2. Which logic structure is used for 'sequential' execution in shell scripting?**

- A) Looping logic
- B) Decision logic
- C) Sequential logic
- D) Case logic

**3. What is the purpose of the environment variable 'HOME'?**

- A) To identify the current shell being used
- B) To set the primary prompt string
- C) To store the fully qualified name of your login directory
- D) To list the search path for commands

**4. Which variable contains the search path for commands?**

- A) MANPATH
- B) PATH
- C) SHELL
- D) PWD

**5. What does the 'PWD' environment variable represent?**

- A) The primary password of the user
- B) The process ID of the shell
- C) The current working directory
- D) The terminal type being used

**6. How are global variables typically written in shell scripting?**

- A) In all lowercase letters
- B) Capitalized (uppercase)
- C) Starting with a number
- D) Inside double brackets [[ ]]

**7. How long does a local variable created within a shell script remain in existence?**

- A) Until the system reboots
- B) Until the user logs out
- C) Only within that specific shell
- D) Permanently in the user's home directory

**8. What are variables like $0, $1, and $2 called?**

- A) Global Variables
- B) Positional Parameters
- C) Arithmetic Expansions
- D) Command Substitutions

**9. Which of the following is true regarding variable types in shell scripts?**

- A) They must be declared as integers or strings
- B) Variables in shell scripts are not typed
- C) They only support floating-point numbers
- D) Variables must be declared before the shebang

**10. What is the correct syntax for assigning the value 'Alice' to the variable 'NAME'?**

- A) set NAME = Alice
- B) NAME : "Alice"
- C) NAME="Alice"
- D) NAME = "Alice"

**11. Which operator is used to append a value to an existing variable?**

- A) +=
- B) ++
- C) ==
- D) =+

**12. Which symbol is required to access the value stored in a variable?**

- A) &
- B) #
- C) %
- D) $

**13. If VAR=123, what is the output of 'echo ${VAR}456'?**

- A) 123
- B) VAR456
- C) 123456
- D) Error: Variable not found

**14. Which syntax is used for command substitution?**

- A) ${command}
- B) $((command))
- C) $(command)
- D) #{command}

**15. What is the output of 'echo ${FILE_NAME:0:5}' if FILE_NAME is 'rocky-linux-8.txt'?**

- A) rocky
- B) linux
- C) rocky-
- D) txt

**16. Which syntax would you use to replace 'Linux' with 'Server' in the variable OS_NAME?**

- A) ${OS_NAME/Linux/Server}
- B) $(OS_NAME -replace Linux Server)
- C) ${OS_NAME//Server/Linux}
- D) replace(OS_NAME, Linux, Server)

**17. How do you provide a default value (e.g., 8080) if the variable PORT is not set?**

- A) ${PORT:=8080}
- B) ${PORT:-8080}
- C) $(PORT || 8080)
- D) ${PORT?8080}

**18. What does the syntax $(( 1+1 )) perform?**

- A) Parameter Expansion
- B) Command Substitution
- C) Arithmetic Expansion
- D) Logic Structuring

**19. What happens to environment variables exported in a shell when you logout?**

- A) They are saved to the .bashrc file
- B) They are lost
- C) They are converted to local variables
- D) They are passed to the kernel

**20. Which of the following is a variable naming best practice?**

- A) Start names with a number for easy sorting
- B) Use system reserved names like PATH for custom scripts
- C) Use meaningful names and consistent styles
- D) Never use underscores

**21. In a shell script, what does $0 represent?**

- A) The first command line parameter
- B) The name of the script itself
- C) The number of parameters passed
- D) The process ID of the shell

**22. Which special variable provides the number of command line parameters?**

- A) $?
- B) $$
- C) $#
- D) $*

**23. What does the variable '$?' represent?**

- A) The process ID of the current shell
- B) A random number for script testing
- C) The exit code of the last command
- D) The user's login name

**24. Which command is used to capture user input from the standard input location?**

- A) input
- B) get
- C) read
- D) fetch

**25. If a 'read' statement expects three variables but the user only enters two, what happens to the third variable?**

- A) The script terminates with an error
- B) It is set to a blank value (' ')
- C) It inherits the value of the second variable
- D) It prompts the user again

**26. What is the primary purpose of using curly braces {} when referencing variables (e.g., ${VAR})?**

- A) To perform mathematical calculations
- B) To avoid misunderstanding or ambiguity with adjacent text
- C) To make the variable global
- D) To encrypt the variable value

**27. Which environment variable identifies the display used by the X-Windows system?**

- A) TERM
- B) DISPLAY
- C) PS1
- D) SHELL

**28. What command is used to make a script executable for the user?**

- A) chmod u+x filename
- B) run filename
- C) make-exec filename
- D) sudo filename

**29. Which of these variables represents the process ID (PID) of the shell?**

- A) $#
- B) $?
- C) $$
- D) $1

**30. In the command 'myinputs.sh DAVID JOHN TINA', what value is stored in $2?**

- A) myinputs.sh
- B) DAVID
- C) JOHN
- D) 3

