# Linux Commands Cheat Sheet

Day 03 of #90DaysOfDevOps.

These are the commands I keep coming back to, grouped as: file system, processes, and networking. For each one, I wrote
what I actually use it for, not the textbook definition, so this stays
easy to scan when something is broken and I'm in a hurry.

---

## File System

| Command | What I use it for |
|---|---|
| `pwd` | shows which directory I'm in |
| `ls -lh` | list files with sizes and permissions in a readable format |
| `cd /var/log` | move into a directory (logs live here, so I go often) |
| `cat file.txt` | print a file to the screen |
| `less file.txt` | open a file page by page, `q` to quit |
| `grep "error" app.log` | find lines containing a word inside a file |
| `find / -name "nginx.conf"` | search the whole system for a file by name |
| `cp` / `mv` / `rm` | copy, move/rename, delete |
| `mkdir -p a/b/c` | create a directory, including parent folders |
| `df -h` | how much disk space is left, per partition |
| `du -sh *` | which folder is eating the disk |

---

## Process Management

| Command | What I use it for |
|---|---|
| `top` | live view of CPU and memory usage, per process |
| `ps aux` | list every running process |
| `ps aux \| grep nginx` | check if a specific process is running |
| `kill <PID>` | ask a process to stop |
| `kill -9 <PID>` | force it to stop when it won't listen |
| `free -h` | how much memory is used and available |
| `systemctl status nginx` | is the service running, and what happened last |
| `systemctl restart nginx` | restart a service |

---

## Logs

| Command | What I use it for |
|---|---|
| `journalctl -u nginx` | full logs for one service |
| `journalctl -u nginx --since "10 min ago"` | just the recent logs, which is usually what I need |
| `tail -f /var/log/app.log` | watch a log live as new lines come in |

---

## Networking Troubleshooting

| Command | What I use it for |
|---|---|
| `ping google.com` | is the machine connected to the internet at all |
| `ip addr` | what IP addresses this machine has |
| `curl -I https://mysite.com` | is the site responding, and with what status code |
| `ss -tulpn` | which ports are open and which process owns them |
| `dig mysite.com` | is DNS resolving to the right IP |

---

## Permissions and Packages

| Command | What I use it for |
|---|---|
| `sudo <command>` | run something as admin |
| `chmod +x script.sh` | make a script executable |
| `chown user:group file` | change who owns a file |
| `sudo apt update && sudo apt upgrade` | refresh package lists and update everything |
| `man <command>` | the built-in manual, for when I forget how any of these work |

---

One thing I noticed while writing this: the useful way to remember
commands is not by name, but by the question they answer. Is the
server reachable? What's using the CPU? Am I out of disk? The commands
are just how you ask.

I'll keep adding to this file as I hit real problems during the
challenge.
