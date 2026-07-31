# Linux Troubleshooting Runbook — mysqld

**Day 05 of #90DaysOfDevOps**

## Overview

For today's troubleshooting drill, I chose **mysqld (MySQL Community Server 9.5.0)** as my target service. I first noticed it during Day 4 while exploring the processes running on my machine. Rather than stopping it immediately, I wanted to understand whether it was healthy, what resources it was using, where it was logging, and whether there were any signs of a problem.

The goal of this runbook isn't to fix a broken service. It's to follow a repeatable troubleshooting process that I could use during a real incident.

---

# Target Service

**Service:** `mysqld`

**Why this service?**

It was already running on my machine, making it a good candidate for practicing a real troubleshooting workflow instead of creating an artificial example.

---

# 1. Environment Check

## Why am I checking this?

Before troubleshooting any service, it's useful to know what operating system I'm working on. Different operating systems store logs, manage services, and organize files differently.

## Commands

```bash
uname -a
sw_vers
```

## Understanding the commands

- `uname -a`
  - `uname` means **Unix Name**.
  - `-a` displays detailed system information, including the kernel and processor architecture.

- `sw_vers`
  - Shows the installed macOS version.

## My Output

```text
$ uname -a
Darwin ... 25.5.0 ... RELEASE_ARM64_T8132 arm64

$ sw_vers
macOS 26.5.1 (25F80)
```

## Interpretation

The machine is running macOS on Apple Silicon (`arm64`). Knowing the operating system helps me choose the correct troubleshooting commands later in the investigation.

---

# 2. Filesystem Sanity Check

## Why am I checking this?

If the filesystem is read-only or completely full, applications may fail to start or save data correctly. Before blaming the application, it's worth confirming that basic file operations work.

## Commands

```bash
mkdir -p /tmp/runbook-demo
cp /etc/hosts /tmp/runbook-demo/hosts-copy
ls -l /tmp/runbook-demo
```

## Understanding the commands

- `mkdir` creates a directory.
- `-p` creates the directory only if it doesn't already exist.
- `cp` copies a file.
- `ls -l` lists files with details like permissions, owner and size.

## My Output

```text
-rw-r--r-- 1 snigdha wheel 213 Jul 31 11:39 hosts-copy
```

## Interpretation

The filesystem behaved normally. I was able to create a directory, copy a file, and verify that it existed afterwards. This rules out obvious filesystem issues before moving on.

---

# 3. CPU & Memory Snapshot

## Why am I checking this?

If a service is slow or unresponsive, one of the first things to check is whether it's consuming excessive CPU or memory.

## Commands

```bash
ps -o pid,pcpu,pmem,etime,comm -p $(pgrep -x mysqld)
vm_stat | head -8
```

## Understanding the commands

- `ps` displays information about running processes.
- `pgrep -x mysqld` finds the PID of the MySQL process.
- `pid` is the Process ID.
- `pcpu` shows CPU usage.
- `pmem` shows memory usage.
- `etime` shows how long the process has been running.
- `comm` displays the executable name.
- `vm_stat` shows memory statistics for macOS.

## My Output

```text
PID   %CPU %MEM ELAPSED COMM
562   0.2  2.3   19:11 /usr/local/mysql/bin/mysqld
```

## Interpretation

MySQL was almost idle, using only **0.2% CPU** and **2.3% memory**. The service had been running since boot and showed no signs of resource pressure.

I also noticed the PID had changed compared to the previous day. This reminded me that PIDs change whenever a process restarts, so it's better to identify services by their name rather than by a specific PID.

---

# 4. Disk & I/O Check

## Why am I checking this?

Databases constantly read and write data. If the disk is almost full or experiencing heavy I/O, performance problems are likely to follow.

## Commands

```bash
df -h /
sudo du -sh /usr/local/mysql/data
iostat
```

## Understanding the commands

- `df -h` shows total, used and available disk space.
- `du -sh` shows the size of a specific directory.
- `iostat` displays disk activity and system load.

## My Output

```text
Disk Available: 18 GiB
MySQL Data Directory: 201 MB
```

## Interpretation

The MySQL data directory is relatively small, so the database itself isn't consuming much storage.

However, the entire system only has **18 GB** of free space remaining. While this isn't immediately critical, it's something worth monitoring because databases don't perform well when disks become nearly full.

---

# 5. Network Check

## Why am I checking this?

Even if a service is running, clients won't be able to use it unless it's listening on the expected network port.

## Commands

```bash
lsof -i :3306
nc -vz localhost 3306
sudo lsof -i :3306
```

## Understanding the commands

- `lsof` shows which process owns a file or network socket.
- `-i :3306` filters the output to port 3306.
- `nc` (Netcat) attempts to connect to a network port.
- `sudo` allows me to view processes owned by other users.

## My Output

```text
lsof
(empty)

nc
Connection to localhost port 3306 succeeded.

sudo lsof
mysqld ... TCP *:3306 (LISTEN)
```

## Interpretation

At first this looked confusing.

`lsof` showed nothing, but `nc` successfully connected.

The reason was permissions. MySQL runs as the `_mysql` user, so running `lsof` without `sudo` couldn't see its network socket.

I also noticed MySQL was listening on `*:3306`, meaning it accepts connections on all network interfaces instead of only `localhost`. For a personal development machine, restricting it to localhost would usually be a safer choice.

---

# 6. Logs Review

## Why am I checking this?

Resource usage tells me what is happening right now.

Logs tell me what happened before I started investigating.

## Commands

```bash
log show --last 5m --predicate 'process == "mysqld"'
sudo tail -n 15 /usr/local/mysql/data/mysqld.local.err
```

## Understanding the commands

- `log show` displays entries from macOS's unified logging system.
- `tail -n 15` displays the last 15 lines of a log file.

## My Output

The unified system log didn't contain any MySQL entries.

The MySQL error log showed:

- Clean shutdown
- Successful startup
- InnoDB initialized correctly
- Server ready for connections

## Interpretation

This taught me that not every application writes to the operating system's central logging system.

MySQL maintains its own log file, and that's where I found the information I needed.

The logs showed a healthy startup with no critical errors.

---

# Quick Findings

- MySQL is healthy and using very little CPU or memory.
- The database occupies only about **201 MB** of storage.
- The service started successfully and the logs contain no critical errors.
- MySQL is listening on **all network interfaces**, which is something I would change on a personal development machine.
- Running `lsof` without `sudo` can hide services owned by another user, so an empty result doesn't always mean nothing is running.

---

# If This Worsens

If MySQL starts showing problems in the future, these would be my next steps:

1. Restrict MySQL to `localhost` by updating the configuration if remote access isn't required.
2. Monitor available disk space and clean up storage before the disk becomes critically full.
3. If CPU or memory usage suddenly increases, capture evidence first (`ps`, logs, and `SHOW PROCESSLIST`) before restarting the service.

---

# What I Learned

Today's exercise taught me that troubleshooting isn't about finding one magic command.

It's about collecting evidence in a logical order.

Instead of jumping straight to restarting a service, I learned to:

- identify the environment,
- verify the filesystem,
- check CPU and memory usage,
- inspect disk and network health,
- review logs,
- interpret the evidence,
- and only then decide what action to take.

That's a workflow I can reuse whenever I troubleshoot another service, whether it's MySQL, Docker, Nginx, or any future application.
