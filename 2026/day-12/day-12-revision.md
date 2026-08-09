# Day 12 – Revision: Linux Fundamentals

## Overview

Today was a revision day for the concepts covered in Days 01–11.

Instead of learning something new, I went through my previous notes and GitHub files to connect the concepts and revisit the commands I am most likely to use while working with Linux.

One thing that stood out during the revision was that memorising commands is not enough. Commands make more sense when I connect them to the problem they help solve.

For example:

* Service not working → check `systemctl status`
* Need to know why → check `journalctl`
* System is slow → check processes using `top`
* Disk is filling up → use `df` and `du`
* Permission denied → check `ls -l` and use `chmod`
* Wrong file owner → use `chown` or `chgrp`

---

# Key Concepts I Revised

## 1. How Linux Works

Linux can be understood in simple layers:

```text
Applications
    ↓
Shell
    ↓
Kernel
    ↓
Hardware
```

* The **kernel** manages resources such as processes, memory, filesystems, and hardware.
* The **shell** allows users to interact with the system using commands.
* Applications run on top of the operating system.

I also revised the Linux boot flow:

```text
Power On
    ↓
BIOS / UEFI
    ↓
Bootloader
    ↓
Kernel
    ↓
systemd
    ↓
Services
    ↓
Login
```

`systemd` plays an important role by starting and managing services after the system boots.

---

## 2. Processes and Services

A **process** is a program that is currently running.

Useful commands:

```bash
ps aux
top
ps -p <PID> -o pid,ppid,command
kill <PID>
```

A **service** is a program managed by the operating system.

Useful commands:

```bash
systemctl status <service>
sudo systemctl start <service>
sudo systemctl restart <service>
sudo systemctl enable <service>
systemctl is-enabled <service>
```

Important difference:

```text
start  → starts the service now
enable → starts the service automatically during boot
```

---

## 3. Logs and Troubleshooting

Logs help explain what happened when a service or application has a problem.

Commands revised:

```bash
journalctl -u <service>
journalctl -u <service> -n 50
journalctl -u <service> -f
tail -f <log-file>
```

A simple troubleshooting flow I want to remember:

```text
Check status
    ↓
Check logs
    ↓
Identify the problem
    ↓
Apply a fix
    ↓
Verify the result
```

---

## 4. Linux File System

Important locations I revised:

```text
/         → Root of the filesystem
/home     → User home directories
/root     → Root user's home directory
/etc      → System and application configuration
/var/log  → System and application logs
/tmp      → Temporary files
/bin      → Essential commands
/usr/bin  → Common commands and utilities
/opt      → Optional or third-party software
```

Commands:

```bash
pwd
cd
cd ..
ls
ls -l
ls -la
```

The locations I think will be especially important while troubleshooting are:

* `/etc` for configuration
* `/var/log` for logs
* `/home` for user files

---

## 5. File Operations

Commands revised:

```bash
touch file.txt
mkdir directory
mkdir -p a/b/c
cp source destination
mv old-name new-name
rm file.txt
cat file.txt
less file.txt
head -n 5 file.txt
tail -n 5 file.txt
```

I also revised the difference between:

```bash
echo "text" > file.txt
```

and:

```bash
echo "text" >> file.txt
```

```text
>   → overwrite existing content
>>  → append content
```

---

## 6. Disk Usage

Useful commands:

```bash
df -h
du -sh *
```

For finding large entries inside `/var/log`:

```bash
du -sh /var/log/* 2>/dev/null | sort -h | tail -5
```

These commands are useful when investigating disk space issues.

---

## 7. Permissions

Linux permissions are based on:

```text
r → read
w → write
x → execute
```

They apply to:

```text
Owner | Group | Others
```

Useful commands:

```bash
ls -l
chmod +x script.sh
chmod -w file.txt
chmod 755 file.txt
```

Numeric values:

```text
Read    = 4
Write   = 2
Execute = 1
```

Example:

```bash
chmod 755 script.sh
```

means:

```text
Owner   → rwx
Group   → r-x
Others  → r-x
```

---

## 8. Users, Groups and Ownership

Every file has an owner and a group.

Check them using:

```bash
ls -l
```

Commands revised:

```bash
id username
sudo useradd -m username
sudo groupadd groupname
sudo chown username file.txt
sudo chgrp groupname file.txt
sudo chown username:groupname file.txt
sudo chown -R username:groupname directory/
```

The three commands I want to remember clearly are:

```text
chmod → changes permissions
chown → changes owner
chgrp → changes group
```

After making changes, always verify with:

```bash
ls -l
```

---

# My Go-To Commands Right Now

These are the five commands I would probably reach for first during a basic Linux issue:

### 1. `systemctl status <service>`

To check whether a service is running, stopped, or failed.

### 2. `journalctl -u <service> -n 50`

To check recent logs and understand why a service may have failed.

### 3. `top`

To check CPU and memory usage when a system is slow.

### 4. `df -h`

To quickly check available disk space.

### 5. `ls -l`

To check file permissions, ownership, and group information.

---

# Mini Self-Check

## 1. Which 3 commands save you the most time right now, and why?

### `systemctl status`

It quickly tells me whether a service is running, stopped, or failed.

### `journalctl -u <service> -n 50`

It helps me check recent logs instead of guessing why a service is not working.

### `ls -l`

It gives me useful information about a file, including its permissions, owner, and group.

---

## 2. How do you check if a service is healthy?

The first commands I would run are:

```bash
systemctl status <service>
```

Then:

```bash
journalctl -u <service> -n 50
```

If I need to watch what happens while testing:

```bash
journalctl -u <service> -f
```

---

## 3. How do you safely change ownership and permissions without breaking access?

First, I check the current permissions and ownership:

```bash
ls -l file.txt
```

Then I make the required change.

For example:

```bash
sudo chown username:groupname file.txt
chmod 640 file.txt
```

Finally, I verify the result:

```bash
ls -l file.txt
```

The important part is not changing permissions or ownership blindly. I should first understand what access is required and verify the result after making the change.

---

## 4. What will I focus on improving in the next 3 days?

I want to focus on:

* Becoming more comfortable with Linux troubleshooting commands.
* Understanding permissions and ownership more confidently in different scenarios.
* Practising how processes, services, logs, files, and permissions connect during real troubleshooting.

---

# Final Takeaway

After revising Days 01–11, the biggest thing I reinforced was that Linux commands are easier to remember when I connect them to the problems they solve.

Instead of trying to memorise commands individually, I want to keep thinking in terms of questions:

```text
What's running?
Is the service healthy?
What do the logs say?
Where is the configuration?
What's using disk space?
Why is access denied?
Who owns this file?
```

The commands are simply the tools used to answer those questions.

## Revision Complete

* [x] Reviewed Days 01–11 notes
* [x] Revised Linux architecture and boot process
* [x] Revised processes and services
* [x] Revised `systemctl` and `journalctl`
* [x] Revised filesystem locations
* [x] Revised file operations
* [x] Revised disk usage commands
* [x] Revised permissions
* [x] Revised users, groups, and ownership
* [x] Completed mini self-check
