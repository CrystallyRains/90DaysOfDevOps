# Linux Troubleshooting Runbook — mysqld

**Day 05 of #90DaysOfDevOps**

## Overview

For today's troubleshooting drill, I chose **mysqld (MySQL Community Server 9.5.0)** as the service to investigate.

I first came across this service during my Day 4 process audit. At the time, I noticed it running in the background and consuming memory, but I didn't know much about it. Instead of assuming it was unnecessary or stopping it immediately, I wanted to investigate it properly.

The goal of this runbook isn't to fix a broken service. It's to follow a repeatable troubleshooting process that I could use during a real incident. Rather than jumping straight to restarting a service, I wanted to collect evidence first, understand what the system was telling me, and then decide whether any action was actually needed.

Every command and output below is from my own machine.

---

# Target Service

**Service:** `mysqld`

**Version:** MySQL Community Server 9.5.0

I chose this service because it was already running on my machine. Instead of creating a fake troubleshooting scenario, I wanted to investigate a real service and understand how it behaved.

---

# Environment Basics

## Why am I checking this?

Before troubleshooting any service, I first want to know what operating system I'm working on. This helps me understand which commands, log locations, and service management tools are available. Many troubleshooting steps depend on the operating system, so this is always a good place to start.

## Commands

```bash
uname -a

sw_vers
```

## Understanding the commands

### `uname -a`

- `uname` stands for **Unix Name**.
- It displays information about the operating system.
- The `-a` option means **all**, so it shows the kernel version, machine architecture and other system details.

### `sw_vers`

`sw_vers` is a macOS command that displays the operating system version and build number.

## My Output

```text
$ uname -a
Darwin ... 25.5.0 ... RELEASE_ARM64_T8132 arm64

$ sw_vers
macOS 26.5.1 (25F80)
```

## Interpretation

This tells me I'm working on macOS running on Apple Silicon (`arm64`).

Knowing the operating system helps me choose the correct commands throughout the investigation. While the overall troubleshooting process is the same, different operating systems may use different tools or store logs in different locations.

---

# Filesystem Sanity Check

## Why am I checking this?

Before investigating the service itself, I want to make sure the filesystem is behaving normally. If the disk is read-only or completely full, applications may fail even though the application itself isn't at fault.

A quick filesystem test helps rule out these obvious issues.

## Commands

```bash
mkdir -p /tmp/runbook-demo

cp /etc/hosts /tmp/runbook-demo/hosts-copy

ls -l /tmp/runbook-demo
```

## Understanding the commands

### `mkdir -p`

- `mkdir` creates a directory.
- `-p` creates the directory only if it doesn't already exist and doesn't throw an error if it does.

### `cp`

`cp` copies a file from one location to another.

### `ls -l`

- `ls` lists the contents of a directory.
- `-l` displays additional details such as file permissions, owner, size and modification date.

## My Output

```text
-rw-r--r-- 1 snigdha wheel 213 Jul 31 11:39 hosts-copy
```

## Interpretation

The directory was created successfully, the file copied without any issues, and I could verify that it existed afterwards.

Although this is a very simple test, it confirms that basic file operations are working correctly. That gives me confidence that the filesystem itself isn't the reason for any problems I might discover later.

---

# Snapshot: CPU & Memory

## Why am I checking this?

If a service becomes slow or unresponsive, one of the first things I want to know is whether it's under heavy CPU or memory load.

Checking resource usage before making any changes helps avoid unnecessary restarts and gives me a baseline for the service's current health.

## Commands

```bash
ps -o pid,pcpu,pmem,etime,comm -p $(pgrep -x mysqld)

vm_stat | head -8
```

## Understanding the commands

### `ps`

`ps` displays information about running processes.

### `-o`

Allows me to choose exactly which columns I want to display.

### The selected columns

- **pid** – Process ID. Every running process receives a unique ID.
- **pcpu** – Percentage of CPU currently being used.
- **pmem** – Percentage of system memory being used.
- **etime** – How long the process has been running.
- **comm** – The executable (program) name.

### `pgrep -x mysqld`

Instead of searching through hundreds of running processes, `pgrep` finds the PID of the process whose name exactly matches `mysqld`. The `$(...)` passes that PID directly into the `ps` command.

### `vm_stat`

`vm_stat` displays memory statistics on macOS. It shows how the operating system is managing RAM.

## My Output

```text
$ ps -o pid,pcpu,pmem,etime,comm -p $(pgrep -x mysqld)

PID  %CPU %MEM ELAPSED COMM
562   0.2  2.3   19:11 /usr/local/mysql/bin/mysqld

$ vm_stat | head -8

Pages free: 7309.
Pages active: 421880.
Pages wired down: 130327.
...
```

## Interpretation

The MySQL service is almost idle. It's using only **0.2% CPU** and **2.3% memory**, which tells me it isn't placing any significant load on the system.

One interesting observation is that yesterday the process ID was **573**, while today it's **562**. That reminded me that PIDs are temporary—they change whenever a process restarts. That's why it's better to identify services by their name rather than relying on a specific PID.

At first, seeing very little free memory in `vm_stat` looked concerning. After reading about it, I learned that macOS intentionally uses unused RAM as cache to improve performance. Low free memory by itself isn't a problem; it's only concerning if the system starts swapping heavily or performance begins to suffer.

---

# Snapshot: Disk & I/O

## Why am I checking this?

Databases constantly read and write data. If the disk is almost full or the system is struggling with disk I/O, even a healthy database can become slow or fail to work correctly. Before blaming MySQL, I wanted to understand whether the storage system itself looked healthy.

## Commands

```bash
df -h /

sudo du -sh /usr/local/mysql/data

iostat
```

## Understanding the commands

### `df -h`

- `df` stands for **Disk Free**.
- It shows how much storage each mounted filesystem is using.
- The `-h` option displays sizes in a human-readable format like MB or GB.

### `du -sh`

- `du` stands for **Disk Usage**.
- It calculates how much space a directory occupies.
- `-s` gives a summary instead of listing every file.
- `-h` again displays the size in a human-readable format.

### `iostat`

`iostat` reports CPU and disk input/output statistics. It helps identify whether the storage subsystem is becoming a bottleneck.

## My Output

```text
$ df -h /

/dev/disk3s1s1   228Gi   12Gi   18Gi   40%   /

$ sudo du -sh /usr/local/mysql/data

201M    /usr/local/mysql/data

$ iostat

KB/t  tps  MB/s  us sy id   1m   5m   15m
20.65 852 17.18 25 11 64 1.65 5.07 6.98
```

## Interpretation

The MySQL data directory is only **201 MB**, so the database itself isn't consuming much storage.

The system still has **18 GB** of available disk space. That's enough for now, but it's something I'd continue monitoring because databases can behave unpredictably when storage becomes critically low.

The load averages were also interesting. They dropped from **6.98 → 5.07 → 1.65**, which suggests the machine was busier shortly after boot and gradually settled down. At the time of my investigation, there was no evidence that disk activity was affecting MySQL.

---

# Snapshot: Network

## Why am I checking this?

A service can be running perfectly but still be unusable if it isn't listening on the expected network port.

For MySQL, the default port is **3306**, so I wanted to verify two things:

- Is the service actually accepting connections?
- Who owns that port?

## Commands

```bash
lsof -i :3306

nc -vz localhost 3306

sudo lsof -i :3306
```

## Understanding the commands

### `lsof`

`lsof` stands for **List Open Files**.

In Unix-like operating systems, network sockets are treated as files. That means `lsof` can also show which process owns a network port.

### `-i :3306`

Filters the output so only port **3306** is shown.

### `nc`

`nc` (Netcat) is often called the "Swiss Army knife of networking."

Here, I used it simply to test whether something was listening on port **3306**.

### `sudo`

Runs the command with elevated privileges.

Without it, I can only see processes owned by my own user account.

## My Output

```text
$ lsof -i :3306

(empty)

$ nc -vz localhost 3306

Connection to localhost port 3306 [tcp/mysql] succeeded!

$ sudo lsof -i :3306

mysqld 562 _mysql ... TCP *:mysql (LISTEN)
```

## Interpretation

This was probably the most interesting part of today's investigation.

At first, `lsof` showed nothing, making it seem like nothing was listening on port **3306**.

However, `nc` successfully connected to the port, proving that MySQL was definitely running.

The explanation turned out to be permissions. MySQL runs under the `_mysql` user, so running `lsof` without `sudo` couldn't see the socket it owned.

This was a useful reminder that an empty command output doesn't always mean "nothing is running." Sometimes it simply means I'm looking without sufficient permissions.

I also noticed that MySQL was listening on **`*:3306`**, which means it accepts connections on every network interface rather than only `localhost`.

While that's acceptable for a server intended to accept remote connections, it's usually unnecessary on a personal development machine. Restricting it to `127.0.0.1` would reduce unnecessary network exposure.

---

# Logs Reviewed

## Why am I checking this?

Resource usage tells me what the service is doing **right now**.

Logs tell me what happened **before** I started investigating.

That's why checking logs is one of the most important parts of any troubleshooting process.

## Commands

```bash
log show --last 5m --predicate 'process == "mysqld"' | tail -5

sudo ls -lh /usr/local/mysql/data/ | grep -i err

sudo tail -n 15 /usr/local/mysql/data/mysqld.local.err
```

## Understanding the commands

### `log show`

Displays entries from macOS's unified logging system.

### `tail -n 15`

Shows only the last 15 lines of a file, making it easier to focus on the most recent events.

### `grep`

Searches text for a matching pattern.

Here, I used it to locate MySQL's error log.

## My Output

```text
$ log show --last 5m --predicate 'process == "mysqld"' | tail -5

(empty)

$ sudo ls -lh /usr/local/mysql/data/ | grep -i err

-rw-r----- 1 _mysql _mysql 452K mysqld.local.err

$ sudo tail -n 15 /usr/local/mysql/data/mysqld.local.err

Received SHUTDOWN from user...
MySQL Server - start.
starting as process 562
InnoDB initialization has ended.
X Plugin ready...
ready for connections.
```

## Interpretation

The macOS unified log didn't contain any entries for MySQL.

Instead, MySQL maintains its own error log inside its data directory.

The log showed a clean shutdown the previous day followed by a successful startup during boot. InnoDB initialized correctly, and the server became ready for connections without any critical errors.

One useful lesson from this section is that not every application writes to the operating system's central logging system. Part of troubleshooting is knowing **where a service keeps its logs**.

---

# Quick Findings

After checking the system, I didn't find any evidence that MySQL was unhealthy.

The service was using very little CPU and memory, the data directory was relatively small, and the logs showed a clean startup without any serious errors.

The main thing that stood out was that MySQL was listening on **all network interfaces** (`*:3306`) instead of only `localhost`. While this isn't necessarily wrong, it's something I would change on a development laptop where remote access isn't required.

I also learned two valuable troubleshooting lessons today:

- An empty command output doesn't always mean nothing is running—it can simply be a permissions issue.
- Not every application logs to the operating system's logging system, so it's important to know where a service stores its own logs.

---

# If This Worsens

If I noticed MySQL becoming slow or unstable in the future, these would be my next steps:

1. Restrict MySQL to `127.0.0.1` if remote connections aren't needed, reducing unnecessary network exposure.

2. Monitor available disk space and clean up storage if free space continues to decrease. Running out of disk space can affect the entire system, not just MySQL.

3. If CPU or memory usage suddenly spikes, capture evidence before restarting the service. I would inspect the running queries using `SHOW PROCESSLIST`, collect log entries, and only restart after understanding what caused the issue.

---

# What I Learned

Today's exercise reinforced that troubleshooting isn't about memorizing commands—it's about following a repeatable process.

Instead of guessing or immediately restarting a service, I learned to collect evidence step by step: identify the environment, verify the filesystem, inspect CPU and memory usage, check disk health, test network connectivity, and review logs before deciding what action to take.

I also realized that every command answers a specific question. `ps` tells me how busy a process is, `df` tells me whether storage is becoming a problem, `lsof` tells me who owns a network port, and logs explain what happened before I started investigating.

The biggest takeaway wasn't learning a new command—it was learning to think methodically. A structured troubleshooting workflow is far more valuable than trying random fixes, and it's a habit I'll continue building as I learn more about Linux and DevOps.
