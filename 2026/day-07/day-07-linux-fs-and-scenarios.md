# Day 07 - Linux File System Hierarchy & Scenario-Based Practice

## Overview

Today's focus was understanding where things live in Linux and how to approach troubleshooting step by step.

Instead of memorizing directories and commands, I focused on understanding their purpose and when I would use them in real-world troubleshooting.

---

# Linux File System Hierarchy

## Quick View

```text
/
├── home      → User files
├── root      → Root user's home
├── etc       → Configuration files
├── var/log   → Logs
├── tmp       → Temporary files
├── bin       → Essential commands
├── usr/bin   → User commands
└── opt       → Third-party applications
```

---

## /

**Purpose**

The root directory is the starting point of the entire Linux file system. Every file and directory exists somewhere under `/`.

**Examples**

```text
/home
/etc
/var
```

**I would use this when...**

I need to navigate the system from the top-level directory.

---

## /home

**Purpose**

Stores personal files and directories for regular users.

**Examples**

```text
/home/alice
/home/bob
```

**I would use this when...**

I need to access a user's files, projects, or configuration.

---

## /root

**Purpose**

Home directory of the root (administrator) user.

**Examples**

```text
/root
```

**I would use this when...**

I am performing administrative tasks as the root user.

---

## /etc

**Purpose**

Stores system-wide configuration files used by the operating system and applications.

**Examples**

```text
/etc/hosts
/etc/passwd
/etc/ssh
```

**I would use this when...**

I need to review or modify system or application configuration.

---

## /var/log

**Purpose**

Stores system and application log files.

**Examples**

```text
/var/log/syslog
/var/log/auth.log
```

**I would use this when...**

I am troubleshooting errors, failed services, or application issues.

---

## /tmp

**Purpose**

Stores temporary files created by users and applications.

**Examples**

```text
/tmp
```

**I would use this when...**

I need temporary storage during testing or troubleshooting.

---

## /bin

**Purpose**

Contains essential system commands required for basic operation.

**Examples**

```text
ls
cp
mv
```

**I would use this when...**

I need access to core Linux commands.

---

## /usr/bin

**Purpose**

Contains additional user-level commands and utilities.

**Examples**

```text
grep
find
vim
```

**I would use this when...**

I am using common Linux utilities and tools.

---

## /opt

**Purpose**

Used for optional or third-party software installations.

**Examples**

```text
/opt/myapp
```

**I would use this when...**

I need to locate software installed outside the default system directories.

---

# Hands-On Practice

## Finding Large Log Files

Command:

```bash
du -sh /var/log/* 2>/dev/null | sort -h | tail -5
```

### What I Learned

* `du` shows disk usage.
* `sort -h` sorts file sizes correctly.
* `tail -5` displays the largest entries.
* Useful when investigating disk space issues caused by growing log files.

---

## Exploring Configuration Files

Command:

```bash
cat /etc/hosts
```

### What I Learned

* The hosts file maps hostnames to IP addresses.
* It is commonly used for local name resolution and testing.

---

## Exploring the Home Directory

Command:

```bash
ls -la ~
```

### What I Learned

* Hidden files begin with a dot (`.`).
* User-specific configuration files are often stored in the home directory.
* Examples include `.ssh`, `.aws`, `.gitconfig`, and `.zshrc`.

---

# Scenario-Based Practice

## Scenario 1: Service Not Starting

### Problem

A web application service called `myapp` failed to start after a reboot.

### Solution

**Step 1**

```bash
systemctl status myapp
```

**Why?**

Check whether the service is running, stopped, or failed.

---

**Step 2**

```bash
journalctl -u myapp -n 50
```

**Why?**

Review recent service logs and identify errors.

---

**Step 3**

```bash
systemctl is-enabled myapp
```

**Why?**

Verify whether the service is configured to start automatically during boot.

---

**Step 4**

```bash
systemctl restart myapp
```

**Why?**

Restart the service after fixing the identified issue.

---

### What I Learned

Always check service status first, then logs, then startup configuration.

---

## Scenario 2: High CPU Usage

### Problem

The application server is responding slowly.

### Solution

**Step 1**

```bash
top
```

**Why?**

View CPU and memory usage in real time.

---

**Step 2**

```bash
htop
```

**Why?**

Provides a more user-friendly view of running processes.

---

**Step 3**

```bash
ps aux --sort=-%cpu | head -10
```

**Why?**

Identify the processes consuming the most CPU.

---

**Step 4**

Note the PID of the top process and investigate further.

---

### What I Learned

Start with system-wide visibility, identify the process, then investigate the root cause.

---

## Scenario 3: Finding Service Logs

### Problem

A developer wants to see Docker service logs.

### Solution

**Step 1**

```bash
systemctl status docker
```

**Why?**

Confirm the service status.

---

**Step 2**

```bash
journalctl -u docker -n 50
```

**Why?**

View the most recent Docker logs.

---

**Step 3**

```bash
journalctl -u docker -f
```

**Why?**

Follow logs in real time while reproducing the issue.

---

### What I Learned

For systemd-managed services, `journalctl` is usually the first place to look for logs.

---

## Scenario 4: File Permission Issue

### Problem

A script returns:

```text
Permission denied
```

### Solution

**Step 1**

```bash
ls -l /home/user/backup.sh
```

**Why?**

Check current file permissions.

---

**Step 2**

```bash
chmod +x /home/user/backup.sh
```

**Why?**

Add execute permission.

---

**Step 3**

```bash
ls -l /home/user/backup.sh
```

**Why?**

Verify the execute permission was added successfully.

---

**Step 4**

```bash
./backup.sh
```

**Why?**

Run the script again and confirm the issue is resolved.

---

### What I Learned

A script needs execute (`x`) permission before it can be run.

---

# Key Takeaways

* Linux organizes files into dedicated directories with specific purposes.
* `/etc` is commonly used for configuration.
* `/var/log` is one of the most important locations for troubleshooting.
* Hidden files often store user-specific configuration.
* Effective troubleshooting follows a process: check status, gather logs, identify the cause, and then apply a fix.
* Understanding where files, logs, and configurations live makes troubleshooting faster and more effective.
