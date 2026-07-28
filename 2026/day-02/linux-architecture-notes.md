# Day 02 - Linux Architecture, Processes & systemd

## Objective

Today's goal was to understand how Linux works behind the scenes.

Instead of just learning Linux concepts, we also applied them by launching an AWS EC2 instance, installing Nginx, and deploying a simple HTML webpage.

---

# What I Learned Today

- Linux Architecture
- Virtualization & Hypervisors
- Linux Boot Process
- Linux Processes
- systemd
- Essential Linux Commands
- Package Management
- AWS EC2
- Nginx
- Claude Code

---

# Concepts Learned

## Linux Architecture

Think of Linux as four layers working together.

```text
+----------------------+
|     Applications     |
+----------------------+
           │
           ▼
+----------------------+
|        Shell         |
+----------------------+
           │
           ▼
+----------------------+
|       Kernel         |
+----------------------+
           │
           ▼
+----------------------+
|      Hardware        |
+----------------------+
```

### Hardware

The physical parts of a computer.

Examples:

- CPU
- RAM
- Storage
- Network Card

Without hardware, Linux has nothing to run on.

---

### Kernel

The kernel is the brain of Linux.

Whenever you:

- Open a file
- Run a command
- Use memory
- Connect hardware

the kernel is doing the actual work.

Main responsibilities:

- Process Management
- Memory Management
- File System Management
- Hardware Communication

**Easy way to remember**

Kernel = Brain of Linux

---

### Shell

Whenever we type a command like:

```bash
ls
```

the shell understands it and passes it to the kernel.

Common shells:

- Bash
- Zsh

**Easy way to remember**

You → Shell → Kernel

---

### Applications

These are the programs we use every day.

Examples:

- VS Code
- Chrome
- Docker
- Terminal

Applications interact with the shell and kernel to get work done.

---

## Virtualization

Virtualization lets us run multiple operating systems on the same physical machine.

This is possible because of a **Hypervisor**.

### Type 1 Hypervisor

Runs directly on the hardware.

Examples:

- VMware ESXi
- Microsoft Hyper-V
- Xen

### Type 2 Hypervisor

Runs on top of an operating system.

Examples:

- Oracle VirtualBox
- VMware Workstation

---

## Linux Boot Process

When a Linux machine starts, it follows this sequence:

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

Once the kernel is loaded, `systemd` starts the required services and prepares the system for use.

---

## Linux Processes

A process is simply a program that is currently running.

Some common process states are:

- Running
- Sleeping
- Stopped
- Zombie

Every running process has its own **PID (Process ID)**.

---

## systemd

One question I had was:

**Who starts all the services after Linux boots?**

The answer is **systemd**.

It is the first userspace process started by Linux.

PID = 1

Its responsibilities include:

- Starting services
- Managing services
- Restarting failed services
- Handling dependencies
- Managing the boot process

Useful command:

```bash
systemctl status nginx
```

---

## Package Management

I always used to confuse these two commands.

### Update

```bash
sudo apt-get update
```

Refreshes the package list.

Think:

**"Check what updates are available."**

---

### Upgrade

```bash
sudo apt-get upgrade
```

Installs the available updates.

Think:

**"Install the available updates."**

---

# Hands-on Lab

Today's session wasn't just about Linux theory.

We also put the concepts into practice by deploying a simple web server on AWS.

Steps we followed:

- Launched an AWS EC2 instance
- Connected to it using SSH
- Updated the package list
- Installed Nginx
- Started the Nginx service
- Generated a simple HTML landing page using Claude Code
- Replaced the default Nginx page
- Accessed the webpage using the EC2 Public IP

This was my first time connecting Linux concepts with an actual deployment, which made today's session much more interesting.

---

# AI in Action

One thing I really liked about today's session was using **Claude Code**.

Instead of spending time writing HTML from scratch, we used AI to generate a simple landing page and focused on understanding the deployment process.

For me, AI didn't replace the learning—it helped speed up a repetitive task so I could spend more time learning Linux, AWS, and Nginx.

---

# Commands Practiced

### Navigation

```bash
pwd
cd
ls
ls -a
```

### File Management

```bash
mkdir
touch
```

### System Information

```bash
df -h
free -m
top
```

### Help

```bash
man ls
```

### Package Management

```bash
sudo apt-get update
sudo apt-get upgrade
```

### Service Management

```bash
systemctl status nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

---

# Key Takeaways

- Linux is built in layers, and each layer has a specific role.
- The kernel is the core of Linux and handles most of the important work.
- The shell acts as a bridge between the user and the kernel.
- `systemd` is responsible for starting and managing services after Linux boots.
- I finally understood the difference between `apt-get update` and `apt-get upgrade`.
- Deploying Nginx on an EC2 instance helped me connect Linux concepts with a real-world task.
- Using Claude Code made the deployment workflow faster while keeping the focus on learning the DevOps concepts.
