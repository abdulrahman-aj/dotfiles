# Privilege elevation

* **Defer root**: prepare and validate as the user; elevate only to continue or finish.
* **Batch root ops**: combine related work in one reviewable elevation; never keep a root shell.
* **Use pkexec**: request graphical approval; never wait for terminal password input.
* **Stop when blocked**: if elevation fails or stalls, return one command and stop.
