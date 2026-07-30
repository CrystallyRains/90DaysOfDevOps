# Day 04 Notes - Processes & Services (My Understanding)

## Goal

The Day 4 task was about understanding:

- Processes
- Services
- Logs
- Basic troubleshooting

The course expected Linux (`systemd`), but I was working on macOS.

Instead of memorizing Linux commands, I learned the **concepts** and used the macOS equivalents.

---

# Linux vs macOS

Linux uses:

- systemd
- systemctl
- journalctl

macOS uses:

- launchd
- launchctl
- log show

Different commands.

Same concepts.

---

# Step 1 - What is running on my machine?

First I wanted to answer a simple question:

> "What is my computer actually running?"

I used:

```bash
ps aux
```

This prints every running process.

Think of it as:

> A list of everything currently alive.

Then I used:

```bash
top
```

Unlike `ps`, this updates continuously and shows which processes are using the most CPU or memory.

From `top` I noticed something interesting.

Although I had only around 10 apps open, there were more than **700 processes** running.

Most of them belong to the operating system.

---

# Step 2 - Spot something unusual

While reading the output, two processes caught my attention.

- mysqld
- node

The Node.js process was using around **350 MB** of memory.

I didn't remember starting it.

Instead of assuming it was normal, I investigated.

---

# Step 3 - Find out what the process actually is

I ran:

```bash
ps -p <PID> -o pid,ppid,command
```

This showed the **complete command** that started the process.

I learned something important.

Process names can be misleading.

The command line tells the real story.

The "node" process turned out to be:

OpenClaw Gateway

It wasn't just Node.js.

It was an AI gateway running in the background.

---

# Step 4 - Is it listening on a network port?

Next question:

> Is this process communicating over the network?

I used:

```bash
lsof -i :18789
```

This showed that the process was listening on port **18789**.

Then I confirmed it by running:

```bash
curl -I http://localhost:18789
```

The server replied with:

HTTP 200 OK

So I confirmed:

- the process was alive
- it was accepting connections

---

# Step 5 - Learn about services

Processes can disappear.

Services are different.

A service is a program that the operating system manages.

If it crashes,

the service manager can automatically restart it.

Linux uses:

systemd

macOS uses:

launchd

---

# Step 6 - List running services

I used:

```bash
launchctl list
```

Then searched for MySQL.

Nothing appeared.

At first I thought MySQL wasn't a service.

That was wrong.

The real reason:

I was only viewing **my own user's services**.

After running:

```bash
sudo launchctl list
```

I found MySQL immediately.

Lesson:

"No output" doesn't always mean something doesn't exist.

Sometimes you're simply looking in the wrong place.

---

# Step 7 - What starts automatically?

I listed my LaunchAgents.

```bash
ls ~/Library/LaunchAgents
```

This showed several programs that automatically start whenever I log in.

Two surprised me.

- OpenClaw
- Hermes

I never realised they were automatically starting.

---

# Step 8 - Read the service definition

Each service had a `.plist` file.

This is similar to a Linux systemd unit file.

Inside I found:

RunAtLoad = true

Meaning:

Start automatically.

I also found:

KeepAlive = true

Meaning:

If I kill the process,

launchd will simply start it again.

That taught me something very important.

You don't stop services by killing the process.

You stop the **service manager**.

---

# Step 9 - Read logs

I practiced two kinds of logs.

Live system logs

```bash
log show --last 1m
```

Traditional log files

```bash
tail -n 10 /var/log/install.log
```

Logs tell you:

- what happened
- when it happened
- which program did it

They're usually the first place to look when something goes wrong.

---

# Step 10 - Remove the service properly

Instead of doing:

```bash
kill
```

I used launchctl.

First:

bootout

Then:

removed the LaunchAgent

Then:

removed the software itself

Finally:

verified everything was gone.

Verification is important.

Never assume something worked.

Always check.

---

# Biggest lessons

## Processes are not services.

A process is something currently running.

A service is something the operating system manages.

---

## Process names can be misleading.

Always inspect the full command.

---

## Services can restart themselves.

If KeepAlive or Restart is enabled,

killing the process isn't enough.

---

## Logs explain what happened.

Commands only show the current state.

Logs explain the history.

---

## Always verify.

Don't trust.

Check.

Use commands to confirm your changes.

---

# Commands I used

```bash
ps aux
top
ps -p PID -o pid,ppid,command
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

# One sentence summary

Today wasn't really about memorizing commands.

It was about learning how to investigate an unknown process, understand the service managing it, inspect its logs, remove it correctly, and verify every step afterwards.
