# Day 04 - Processes and Services

## Overview

Today's goal was to understand how operating systems manage **processes**, **services**, and **logs**.

The course uses Linux, but I completed this exercise on my Mac. Although macOS isn't Linux, both operating systems follow the same ideas. The commands are different, but the concepts are very similar.

Instead of memorizing Linux commands, I focused on understanding **what each command is supposed to do** and then used the macOS equivalent.

---

# Linux vs macOS

| Task | Linux | macOS |
|------|--------|--------|
| Service Manager | systemd | launchd |
| Manage Services | systemctl | launchctl |
| View Service Logs | journalctl | log show |

Although the commands are different, all of them help us answer the same questions:

- What is running?
- Who started it?
- Is it still running?
- Why did it stop?
- What do the logs say?

---

# Step 1 - Looking at Running Processes

The first thing I wanted to understand was:

> **What is actually running on my computer?**

To answer this, I used:

```bash
ps aux
```

This command displays every running process.

A **process** is simply a program that is currently running.

For example:

- Opening Google Chrome creates one or more processes.
- Opening VS Code creates another process.
- Even the operating system runs hundreds of background processes that we normally never see.

When I checked my own machine, I found more than **700 running processes**, even though I only had around 10 applications open.

That taught me that most processes belong to the operating system and background services, not the applications I manually open.

---

# Step 2 - Which Processes Are Using Resources?

Seeing hundreds of processes isn't very helpful unless we know which ones are actually consuming CPU or memory.

For that, I used:

```bash
top -l 1 -o mem
```

Unlike `ps`, which gives a snapshot, `top` shows which processes are using the most system resources.
Command Breakdown: 
- top: Invokes the display of real-time system usage statistics.
- -l 1: Specifies the number of samples (or iterations) to take. Setting it to 1 forces the command to print a non-interactive, static snapshot and then instantly terminate.
- -o mem: Instructs the utility to sort the output processes in descending order based on their physical memory footprint (mem).

While reading the output, two processes caught my attention:

- mysqld
- node

I didn't remember starting either of them, so I decided to investigate further.

---

# Step 3 - Finding the Real Program Behind a Process

At first, I only knew the process name.

However, process names don't always tell the full story.

To see exactly what was running, I used:

```bash
ps -p <PID> -o pid,ppid,command
```

This command displays the complete command that launched the process.

I discovered that the mysterious `node` process was actually running an **OpenClaw AI Gateway**.

That was an important lesson.

The process name only tells you **what executable is running**.

The complete command tells you **what that executable is actually doing**.

---

# Step 4 - Is the Process Listening on the Network?

The next question was:

> Is this process accepting network connections?

To find out, I used:

```bash
lsof -i :18789
```

This showed that the process was listening on **localhost:18789**.

I confirmed it by sending a request using:

```bash
curl -I http://localhost:18789
```

The server responded successfully.

This confirmed two things:

- the process was running
- it was actively accepting connections

I also noticed it was bound to **localhost**.

That means only my own computer could access it.

If it had been bound to all network interfaces, other machines could have reached it as well.

---

# Step 5 - Understanding Services

This exercise also helped me understand the difference between a **process** and a **service**.

A process is something that is currently running.

A service is a program managed by the operating system.

If a service crashes, the operating system can automatically start it again.

On Linux, this is handled by **systemd**.

On macOS, it is handled by **launchd**.

Different names, but the same responsibility.

---

# Step 6 - Listing Services

To see the services managed by macOS, I used:

```bash
launchctl list
```

I searched for MySQL but couldn't find it.

At first, I thought MySQL wasn't running as a service.

Later, I realised my mistake.

The command was only showing services running under my own user account.

After running:

```bash
sudo launchctl list
```

I found the MySQL service immediately.

This taught me an important troubleshooting lesson.

If a command doesn't show what you're expecting, it doesn't always mean something is missing.

Sometimes you're simply looking in the wrong place.

---

# Step 7 - Checking What Starts Automatically

I also wanted to know which programs automatically start when I log into my computer.

For that, I checked:

```bash
ls ~/Library/LaunchAgents
```

This listed several LaunchAgent files.

Among them were:

- OpenClaw
- Hermes
- Google Updater

I hadn't realised these programs were configured to start automatically.

---

# Step 8 - Reading the Service Configuration

Each LaunchAgent contains a `.plist` file.

This is similar to a Linux systemd unit file.

Inside the OpenClaw configuration, I found:

- `RunAtLoad = true`
- `KeepAlive = true`

`RunAtLoad` means the service starts automatically when I log in.

`KeepAlive` means that if the process stops, launchd automatically starts it again.

This explained why simply killing the process wouldn't permanently stop it.

The service manager would immediately restart it.

---

# Step 9 - Looking at Logs

Logs record what the operating system and applications have been doing.

I explored two different types of logs.

Live system logs:

```bash
log show --last 1m
```

Traditional log files:

```bash
tail -n 10 /var/log/install.log
```

These logs showed recent network activity and even confirmed that my Mac had recently checked for operating system updates.

Logs are often the best place to start when investigating a problem because they explain **what happened before you noticed something was wrong**.

---

# Step 10 - Removing an Unwanted Service

Since I no longer needed the OpenClaw and Hermes services, I removed them correctly.

Instead of killing the running process, I:

1. Stopped the service using `launchctl`.
2. Removed the LaunchAgent registration.
3. Uninstalled the software.
4. Verified that the service, process, and listening port were all gone.

This reinforced another important lesson.

Whenever you make changes to a system, don't assume they worked.

Always verify the result.

---

# Key Takeaways

By the end of today's exercise, I understood:

- A **process** is a running program.
- A **service** is a program managed by the operating system.
- Service managers (systemd or launchd) automatically start and monitor services.
- The full command is often more useful than the process name.
- Logs help explain what happened before an issue occurred.
- Background services can start automatically without you remembering they were installed.
- Verifying your changes is just as important as making them.

---

# Commands I Practiced

```bash
ps aux
top
ps -p <PID> -o pid,ppid,command
lsof -i :PORT
curl -I
launchctl list
sudo launchctl list
ls ~/Library/LaunchAgents
cat <plist>
log show
tail
launchctl bootout
pgrep
which
```

---

# Final Thoughts

This exercise wasn't just about learning commands.

It was about understanding how an operating system manages processes and services, how to investigate something unfamiliar, and how to make changes safely while verifying every step.
