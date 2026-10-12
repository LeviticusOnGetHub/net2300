# functions

**1. What are functions in Bash according to the provided material?**

- A) External binary files used for compilation
- B) Reusable blocks of code that help organize scripts and reduce repetition
- C) Variables that store multiple strings at once
- D) Built-in commands like break and continue

**2. Which keyword is optional when defining a function in Bash?**

- A) local
- B) return
- C) function
- D) source

**3. In the syntax 'functionname()', what is required inside the parentheses?**

- A) The list of arguments
- B) The variable types
- C) Nothing; there is no need to specify arguments in the parentheses
- D) The return type

**4. What determines the default exit status of a function if no explicit return is provided?**

- A) The status of the first command in the function
- B) The exit status of the last command executed in the function body
- C) Always 0
- D) The number of arguments passed

**5. How do you call a Bash function named 'my_func' with two arguments 'a' and 'b'?**

- A) call my_func(a, b)
- B) my_func {a, b}
- C) my_func a b
- D) run my_func --args a b

**6. When the shell interprets a command, what does it look for after special built-in functions?**

- A) External scripts
- B) Shell functions
- C) Environment variables
- D) Aliases

**7. Which special variable represents the script name inside a function?**

- A) $1
- B) $#
- C) $@
- D) $0

**8. What does the special variable '$@' represent?**

- A) The number of parameters
- B) The exit status of the last command
- C) All parameters separated by a space
- D) The process ID

**9. In a script, which variable is used to capture the value returned by a function via the 'return' command?**

- A) $?
- B) $!
- C) $*
- D) $$

**10. What is the recommended way to pass a calculation result back to a caller for capture, rather than just an exit status?**

- A) Use 'return 100'
- B) Use 'echo' to output the result
- C) Store it in a local variable
- D) Use the 'exit' command

**11. What happens if you define a variable like 'foo=1' inside a function without the 'local' keyword?**

- A) It becomes a global variable accessible outside the function
- B) It causes a syntax error
- C) It is only available within that specific function
- D) It is treated as a constant

**12. What is the primary difference between 'return' and 'exit' in a function?**

- A) 'return' stops the script, 'exit' continues the script
- B) 'return' passes a status and continues the script; 'exit' stops the entire script
- C) There is no difference between them
- D) 'return' can only return strings, 'exit' only returns numbers

**13. Which command is used to load and run functions defined in another file (like 'tools.sh') into the current script?**

- A) load or import
- B) source or the dot (.) shorthand
- C) include
- D) bash ./tools.sh

**14. What is an interrupt in the context of shell scripting?**

- A) A bug in the code
- B) A signal sent to a process to stop its current activity
- C) A way to pause a script for a specific time
- D) A type of function call

**15. Which signal is triggered by pressing Ctrl+C?**

- A) SIGTERM
- B) EXIT
- C) SIGINT
- D) SIGKILL

**16. What is the purpose of the 'trap' command?**

- A) To catch errors in the script
- B) To register commands to run when specific signals are received
- C) To prevent a function from returning
- D) To lock a file for editing

**17. Which internal signal triggers whenever a script finishes for any reason?**

- A) SIGINT
- B) SIGTERM
- C) EXIT
- D) SIGSTOP

**18. How do you define a variable to be scoped only within a function?**

- A) private varname
- B) scoped varname
- C) local varname
- D) var varname

**19. In the provided 'multiply' function example, how is the output captured into a variable?**

- A) result=multiply 4 5
- B) result=$(multiply 4 5)
- C) result=<multiply 4 5>
- D) result=return multiply 4 5

**20. If a function executes 'ls /nonexistent' followed by 'return 0', what will '$?' be after the function call?**

- A) 1
- B) 2
- C) 0
- D) 127

