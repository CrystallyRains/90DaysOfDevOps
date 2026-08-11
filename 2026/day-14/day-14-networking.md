# Day 14 – Networking Fundamentals & Hands-on Checks

## Overview

Networking is a big part of DevOps troubleshooting.

When an application is not working, we need to find out where the problem is:

- Is the machine connected to the network?
- Can it reach the destination?
- Can DNS resolve the name?
- Is the required port open?
- Is the service running?
- Is the application returning a valid response?

This day focuses on the basic networking commands used to answer these questions.

---

# 1. OSI Model vs TCP/IP Model

## OSI Model

The OSI model has **7 layers**.

It is mainly used as a way to understand how network communication works.

| Layer | Name | What it does | Examples |
|---|---|---|---|
| L7 | Application | Network services used by applications | HTTP, HTTPS, DNS, SSH |
| L6 | Presentation | Data format, encryption, compression | Encryption, encoding |
| L5 | Session | Manages communication sessions | Session management |
| L4 | Transport | End-to-end communication | TCP, UDP |
| L3 | Network | IP addressing and routing | IP, routers |
| L2 | Data Link | Communication on the local network | MAC, Ethernet |
| L1 | Physical | Sends bits through the physical medium | Cables, radio signals |

### Easy way to remember

```text
L7  Application
L6  Presentation
L5  Session
L4  Transport
L3  Network
L2  Data Link
L1  Physical
