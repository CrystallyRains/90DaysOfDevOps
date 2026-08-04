# Day 08 - Cloud Server Setup: Docker, Nginx & Web Deployment

## Overview

As part of today's challenge, I deployed an Nginx web server on an AWS EC2 instance. The deployment involved connecting to the server over SSH, installing and managing the Nginx service, configuring network access, verifying the deployment through a browser, and reviewing service logs for validation and troubleshooting.

---

# Deployment Workflow

```text
Local Machine
      │
      │ SSH (Port 22)
      ▼
AWS EC2 Instance
      │
      │ Install & Manage Nginx
      ▼
Nginx Web Server
      │
      │ HTTP (Port 80)
      ▼
Web Browser
```

---

# Commands Used

## Connect to the EC2 Instance

```bash
ssh -i "l111.pem" ec2-user@<public-ip>
```

Established a secure SSH connection to the Amazon Linux EC2 instance.

---

## Update System Packages

```bash
sudo dnf update -y
```

Updated the system packages before installing new software.

---

## Install Nginx

```bash
sudo dnf install nginx -y
```

Installed the Nginx web server.

---

## Start the Service

```bash
sudo systemctl start nginx
```

Started the Nginx service.

---

## Enable Nginx at Boot

```bash
sudo systemctl enable nginx
```

Configured the service to start automatically after every reboot.

---

## Verify Service Status

```bash
systemctl status nginx
```

**Observed:**

```text
Active: active (running)
```

Confirmed that the service started successfully.

---

## Verify Boot Configuration

```bash
systemctl is-enabled nginx
```

**Observed:**

```text
enabled
```

Verified that Nginx is configured to start automatically.

---

## Review Service Logs

```bash
journalctl -u nginx -n 50
```

Reviewed recent service logs to verify a successful startup and configuration validation.

---

## Export Logs

```bash
journalctl -u nginx -n 50 > nginx-logs.txt
```

Saved the latest Nginx logs into a text file.

---

## Download Logs to Local Machine

```bash
scp -i "l111.pem" ec2-user@<public-ip>:~/nginx-logs.txt .
```

Copied the log file from the EC2 instance to the local machine.

---

# Security Group Configuration

To make the web server accessible from the internet, the following inbound rules were configured:

| Port | Purpose |
|------|---------|
| 22 | SSH Access |
| 80 | HTTP Traffic |

After allowing HTTP traffic, accessing the instance's public IP displayed the default Nginx welcome page.

---

# Deployment Verification

The deployment was validated by completing the following checks:

- Connected to the EC2 instance over SSH.
- Installed and started the Nginx service.
- Verified the service status using `systemctl`.
- Confirmed that Nginx is enabled to start automatically after reboot.
- Reviewed service logs using `journalctl`.
- Successfully accessed the default Nginx webpage through the browser.

---

# Challenges Faced

## Incorrect Service Name

While checking logs, I initially queried an incorrect service name, which returned no log entries.

```bash
journalctl -u my-nginx -n 50
```

After verifying the correct service name, I used:

```bash
journalctl -u nginx -n 50
```

This displayed the expected service logs.

---

## Verifying External Access

The web server was not accessible until HTTP (Port 80) was allowed in the EC2 Security Group.

Once the inbound rule was updated, the Nginx welcome page loaded successfully in the browser.

---

# Key Takeaways

- Reviewed the workflow for deploying an Nginx web server on AWS EC2.
- Used SSH for secure remote server administration.
- Managed services using `systemctl` and verified their operational status.
- Used `journalctl` to inspect service logs during deployment validation.
- Configured Security Groups to allow web traffic.
- Verified the deployment by accessing the application through the server's public IP.

---

# Project Files

- `day-08-cloud-deployment.md`
- `nginx-logs.txt`

---

# Screenshots

### SSH Connection

> *<img width="1666" height="892" alt="image" src="https://github.com/user-attachments/assets/63099070-39de-46c3-abe2-2d02de4c673b" />
*

---

### Nginx Welcome Page

> *<img width="2047" height="714" alt="image" src="https://github.com/user-attachments/assets/5070d3cd-8769-4429-99c5-e70cbc972245" />
*

---

### Nginx Log Output

> *<img width="1682" height="624" alt="image" src="https://github.com/user-attachments/assets/5c8fc04a-b0e2-432a-b627-f1cd88ff3af4" />
*

---

# Conclusion

This exercise reinforced the complete workflow of deploying and validating a web service on a cloud instance. Beyond installing Nginx, it involved service management, network configuration, log inspection, and deployment verification—activities that are part of day-to-day infrastructure operations.
