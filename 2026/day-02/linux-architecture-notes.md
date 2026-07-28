# Day 02 – Linux Architecture, Processes & systemd

## Objective

Today's goal was to understand how Linux works under the hood and why it is the foundation of modern DevOps environments.

Along with learning Linux fundamentals, I also applied these concepts by launching an AWS EC2 instance, installing Nginx, and deploying a simple HTML webpage.

---

## Topics Covered

- Linux Architecture
- Virtualization & Hypervisors
- Linux Boot Process
- Linux Processes
- systemd
- Package Management
- Essential Linux Commands
- AWS EC2
- Nginx
- Claude Code

---

## Concepts Learned

### Linux Architecture

Linux consists of four major layers.

```text
Applications
     │
     ▼
   Shell
     │
     ▼
   Kernel
     │
     ▼
  Hardware
```

### Hardware

The physical components of a computer, such as:

- CPU
- RAM
- Storage
- Network Interface

### Kernel

The kernel is the core of the Linux operating system.

Responsibilities include:

- Process Management
- Memory Management
- Hardware Communication
- File System Management
- CPU Scheduling

### Shell

The shell acts as an interface between the user and the kernel.

Examples:

- Bash
- Zsh

Whenever a command is executed, the shell communicates with the kernel to perform the requested operation.

---

## Virtualization

Virtualization allows multiple operating systems to run on a single physical machine.

This is achieved using a Hypervisor.

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

The Linux boot sequence consists of:

1. Power On
2. BIOS / UEFI
3. Bootloader
4. Linux Kernel
5. systemd (PID 1)
6. System Services
7. User Login

---

## Linux Processes

A process is a running instance of a program.

Some common process states include:

- Running
- Sleeping
- Stopped
- Zombie

Linux assigns every running process a unique Process ID (PID).

---

## systemd

`systemd` is the first userspace process started by Linux (PID 1).

It is responsible for:

- Starting services
- Managing services
- Restarting failed services
- Handling dependencies
- Managing the boot process

Useful command:

```bash
systemctl status
```

---

## Package Management

Update the package index:

```bash
sudo apt-get update
```

Downloads the latest package information from the configured repositories.

Upgrade installed packages:

```bash
sudo apt-get upgrade
```

Installs the available package updates.

---

## Hands-on Lab

To reinforce the concepts learned during the session, I completed a simple deployment exercise on AWS.

Tasks completed:

- Launched an AWS EC2 instance
- Connected to the instance using SSH
- Updated the system packages
- Installed Nginx
- Started the Nginx service
- Replaced the default Nginx page with a custom HTML page
- Accessed the application using the EC2 Public IP

This exercise helped connect Linux fundamentals with a real deployment workflow.

---

## AI in Action

As part of the deployment exercise, we used **Claude Code** to generate a simple HTML landing page.

Instead of spending time writing HTML from scratch, AI helped generate the webpage quickly, allowing the focus to remain on understanding the deployment process with Linux, AWS, and Nginx.

This was a good example of using AI to improve productivity while still learning the underlying concepts.

---

## Commands Practiced

```bash
pwd
cd
ls
ls -a
mkdir
touch
df -h
free -m
top
man ls

sudo apt-get update
sudo apt-get upgrade

sudo apt install nginx

systemctl status nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

---

## Additional Notes

- Ubuntu 24.04 is the latest Long-Term Support (LTS) release.
- `/bin` contains many essential Linux command binaries.
- `man` displays the manual page for Linux commands.
- `sudo` executes commands with superuser privileges.
- Most production servers run Linux, making Linux fundamentals an essential DevOps skill.

---

## Key Takeaways

- Understood the architecture of the Linux operating system.
- Learned how the Linux boot process works.
- Revised commonly used Linux commands.
- Learned the role of `systemd` in managing Linux services.
- Deployed an Nginx web server on AWS EC2.
- Used Claude Code to generate a webpage and deployed it successfully.
- Connected Linux fundamentals with a practical cloud deployment.
