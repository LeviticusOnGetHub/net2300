# net2300 web

**1. What is the primary function of the HTTP protocol in the OSI model?**

- A) Layer 3 - Network
- B) Layer 4 - Transport
- C) Layer 7 - Application
- D) Layer 2 - Data Link

**2. Which port is standard for secure HTTPS traffic?**

- A) 22
- B) 80
- C) 443
- D) 8080

**3. Which component of an HTTP response contains metadata like 'Server: Apache'?**

- A) Status Code
- B) Headers
- C) Body
- D) Payload

**4. Which tool is specifically designed for robust, non-interactive file downloading and website mirroring?**

- A) cURL
- B) Wget
- C) Ping
- D) Traceroute

**5. By default, where does cURL send its output?**

- A) To a .zip file
- B) To the terminal (stdout)
- C) To /dev/null
- D) To a log file

**6. What does the cURL '-O' (uppercase) flag do?**

- A) Saves the file with a custom name
- B) Saves the file using its original remote name
- C) Overwrites existing files
- D) Opens the file after downloading

**7. Which cURL command is used to fetch only the HTTP headers for debugging?**

- A) curl -H
- B) curl -v
- C) curl -I
- D) curl -X

**8. If a URL has moved, which flag tells cURL to follow the redirect?**

- A)  -f
- B)  -L
- C)  -r
- D)  -u

**9. How do you provide a username and password for authentication in cURL?**

- A) curl -a user:pass
- B) curl -p user:pass
- C) curl -u user:pass
- D) curl -H user:pass

**10. Which flag is used to specify a custom request method like DELETE or PUT in cURL?**

- A) -m
- B) -X
- C) -d
- D) -s

**11. What is the purpose of the '-v' flag in cURL?**

- A) Verifies the download
- B) Verbose mode (shows the full handshake)
- C) Validates JSON data
- D) Version information

**12. How do you ignore SSL certificate errors in cURL?**

- A) -k
- B) -i
- C) -s
- D) -ignore

**13. Which tool would you choose to mirror an entire directory structure of a website?**

- A) cURL
- B) Wget
- C) HTTPie
- D) Telnet

**14. Which Wget flag allows you to resume a partial download?**

- A) -r
- B) -m
- C) -c
- D) -o

**15. Which HTTP status code category indicates a 'Successful Response'?**

- A) 1xx
- B) 2xx
- C) 3xx
- D) 4xx

**16. What does the 404 HTTP status code mean?**

- A) Forbidden
- B) Unauthorized
- C) Not Found
- D) Bad Request

**17. Which code is returned when a server is down for maintenance or overloaded?**

- A) 401
- B) 403
- C) 500
- D) 503

**18. In the command 'curl -s -o /dev/null -w "%{http_code}" URL', what does '-s' do?**

- A) Saves the file
- B) Follows shortcuts
- C) Silent mode (suppresses progress meters)
- D) Sets the status code

**19. What is the result of using '-o /dev/null' in a cURL command?**

- A) Deletes the server file
- B) Discards the response body
- C) Creates a null pointer
- D) Forces a 404 error

**20. Which HTTP status code indicates the resource has been permanently moved?**

- A) 200
- B) 301
- C) 307
- D) 410

