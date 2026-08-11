# Day 15 -- Networking Concepts: DNS, IP, Subnets & Ports

## Overview

Day 14 focused on **checking** a network using commands.

Day 15 focuses on understanding the concepts behind those checks:

-   DNS
-   IP addresses
-   Public and private IPs
-   CIDR
-   Subnets
-   Ports
-   Common network services

These are basic networking concepts that come up often in DevOps and
cloud work.

------------------------------------------------------------------------

# Task 1: DNS -- How Names Become IPs

## What happens when you type `google.com` in a browser?

When you type `google.com`, the computer first needs to find the IP
address for that domain.

DNS (Domain Name System) does this name-to-IP lookup.

Once the IP address is known, the browser can connect to the server
using that IP and request the website.

A simplified flow is:

``` text
google.com
    ↓
DNS lookup
    ↓
IP address
    ↓
Connect to the server
    ↓
Website response
```

------------------------------------------------------------------------

## DNS Record Types

### A Record

An **A record** maps a domain name to an **IPv4 address**.

Example:

``` text
google.com → 142.250.x.x
```

### AAAA Record

An **AAAA record** maps a domain name to an **IPv6 address**.

### CNAME Record

A **CNAME** makes one domain name an alias for another domain name.

Example:

``` text
www.example.com → example.com
```

### MX Record

An **MX record** tells us which mail server handles email for a domain.

### NS Record

An **NS record** tells us which name servers are authoritative for a
domain.

------------------------------------------------------------------------

## Check DNS with `dig`

### Command

``` bash
dig google.com
```

### Example output

``` text
$ dig google.com

;; ANSWER SECTION:
google.com.        300     IN      A       142.250.183.14
google.com.        300     IN      A       142.250.183.15
```

From this output:

-   **A record:** `142.250.183.14` and `142.250.183.15`
-   **TTL:** `300` seconds
-   **Record type:** `A`

### What is TTL?

TTL means **Time To Live**.

It tells DNS resolvers how long the record can normally be cached before
it should be looked up again.

------------------------------------------------------------------------

## Quick DNS Revision

``` text
DNS  → Converts names into IP addresses

A    → IPv4
AAAA → IPv6
CNAME → Alias
MX   → Mail server
NS   → Name server
```

------------------------------------------------------------------------

# Task 2: IP Addressing

## What is an IPv4 address?

An IPv4 address is an address used to identify a device/interface on an
IP network.

It contains **32 bits**, divided into four 8-bit sections called octets.

Example:

``` text
192.168.1.10
```

It can be viewed as:

``` text
192  .  168  .  1  .  10
 ↑       ↑      ↑      ↑
Octet   Octet  Octet  Octet
```

Each octet can have a value from:

``` text
0 to 255
```

So IPv4 addresses range from:

``` text
0.0.0.0
```

to:

``` text
255.255.255.255
```

The actual usable meaning of an address depends on the network and
subnet it belongs to.

------------------------------------------------------------------------

## Public vs Private IP

### Private IP

A private IP is used inside a private network.

It is not directly routable over the public Internet.

Example:

``` text
192.168.1.10
```

Private IPs are commonly used inside:

-   Home networks
-   Company networks
-   Cloud private networks

### Public IP

A public IP is an address that can be used for communication over the
public Internet.

Example:

``` text
8.8.8.8
```

------------------------------------------------------------------------

## Private IPv4 Ranges

There are three main private IPv4 ranges:

  Range                             CIDR
  --------------------------------- ------------------
  `10.0.0.0 – 10.255.255.255`       `10.0.0.0/8`
  `172.16.0.0 – 172.31.255.255`     `172.16.0.0/12`
  `192.168.0.0 – 192.168.255.255`   `192.168.0.0/16`

Easy way to remember:

``` text
10.x.x.x
172.16.x.x – 172.31.x.x
192.168.x.x
```

------------------------------------------------------------------------

## Check IP Addresses on Linux

### Command

``` bash
ip addr show
```

### Example output

``` text
$ ip addr show

2: eth0:
    inet 10.0.1.25/24
    inet6 fe80::1234:abcd/64
```

Here:

``` text
10.0.1.25
```

is a **private IPv4 address** because it falls inside the `10.0.0.0/8`
private range.

Another example:

``` text
inet 192.168.1.20/24
```

is also private because it falls inside the `192.168.0.0/16` range.

------------------------------------------------------------------------

# Task 3: CIDR & Subnetting

## What does `/24` mean?

Consider:

``` text
192.168.1.0/24
```

The `/24` tells us that the first **24 bits** are used for the network
portion.

IPv4 has 32 bits in total.

So:

``` text
32 total bits
- 24 network bits
----------------
  8 host bits
```

That leaves **8 bits** for addresses inside the subnet.

------------------------------------------------------------------------

## How many IPs are in a `/24`?

The number of addresses is:

``` text
2^(32 - prefix)
```

For `/24`:

``` text
2^(32 - 24)
= 2^8
= 256 total IPs
```

For a traditional IPv4 subnet, two addresses are normally reserved:

-   Network address
-   Broadcast address

So:

``` text
256 total
- 2 reserved
= 254 usable hosts
```

------------------------------------------------------------------------

## `/16`

``` text
2^(32 - 16)
= 2^16
= 65,536 total IPs
```

Usable hosts:

``` text
65,536 - 2
= 65,534
```

------------------------------------------------------------------------

## `/28`

``` text
2^(32 - 28)
= 2^4
= 16 total IPs
```

Usable hosts:

``` text
16 - 2
= 14
```

------------------------------------------------------------------------

## CIDR Quick Table

  CIDR    Subnet Mask           Total IPs   Usable Hosts
  ------- ------------------- ----------- --------------
  `/24`   `255.255.255.0`             256            254
  `/16`   `255.255.0.0`            65,536         65,534
  `/28`   `255.255.255.240`            16             14

### Easy rule

For normal IPv4 subnet calculations:

``` text
Total IPs = 2^(32 - prefix)
Usable hosts = Total IPs - 2
```

> Note: The `-2` rule is the traditional IPv4 subnet calculation. Some
> cloud platforms, including AWS, reserve additional addresses inside
> each subnet. This becomes important when working with AWS VPCs.

------------------------------------------------------------------------

## Why Do We Subnet?

Subnetting means dividing a larger network into smaller networks.

For example, instead of putting every machine into one large network, we
can create smaller networks for different purposes.

``` text
Large Network
      ↓
 ┌────┼────┐
 ↓    ↓    ↓
Subnet Subnet Subnet
```

Why do this?

-   Better organization
-   Smaller broadcast domains
-   Easier network management
-   Better control over network traffic
-   Better use of IP addresses
-   Useful for separating different types of workloads

In cloud environments, subnets are also used to organize resources such
as application servers, databases and other services.

------------------------------------------------------------------------

# Task 4: Ports -- The Doors to Services

## What is a port?

A port is a number used to identify a particular network service on a
machine.

Think of it like this:

``` text
IP address → Which machine?
Port        → Which service?
```

For example:

``` text
10.0.1.50:3306
```

means:

``` text
10.0.1.50 → destination machine
3306      → destination port
```

Ports allow one machine to run multiple network services at the same
time.

For example, the same server might have:

``` text
22   → SSH
80   → HTTP
443  → HTTPS
```

The IP identifies the machine, while the port helps identify the
service.

------------------------------------------------------------------------

## Common Ports

     Port Service   What it is commonly used for
  ------- --------- ------------------------------
       22 SSH       Secure remote login
       80 HTTP      Web traffic
      443 HTTPS     Secure web traffic
       53 DNS       Domain name resolution
     3306 MySQL     MySQL database
     6379 Redis     Redis database/cache
    27017 MongoDB   MongoDB database

------------------------------------------------------------------------

## Check Listening Ports

### Command

``` bash
sudo ss -tulpn
```

### Example output

``` text
$ sudo ss -tulpn

Netid State  Local Address:Port  Process
tcp   LISTEN 0.0.0.0:22          users:(("sshd",pid=812,fd=3))
tcp   LISTEN 0.0.0.0:80          users:(("nginx",pid=1024,fd=6))
```

From this example:

``` text
Port 22 → SSH → sshd
Port 80 → HTTP → nginx
```

This satisfies the basic idea of matching listening ports to services.

### Why is `ss` useful?

If an application is supposed to listen on port `8080`, we can check
whether anything is actually listening there.

``` bash
sudo ss -tulpn | grep :8080
```

If nothing is returned, there may be no service listening on that port.

------------------------------------------------------------------------

# Task 5: Putting It Together

## Scenario 1

### Command

``` bash
curl http://myapp.com:8080
```

### What networking concepts are involved?

Several concepts are involved:

1.  **DNS** may resolve `myapp.com` to an IP address.
2.  **IP** is used to reach that server.
3.  **Port 8080** identifies the application/service.
4.  **HTTP** is used to send the web request.

Simplified:

``` text
myapp.com
    ↓
DNS
    ↓
IP address
    ↓
TCP connection
    ↓
Port 8080
    ↓
HTTP request
```

------------------------------------------------------------------------

## Scenario 2

### Problem

The application cannot reach:

``` text
10.0.1.50:3306
```

### What would I check first?

First, check whether the destination is reachable:

``` bash
ping 10.0.1.50
```

Then check whether port `3306` is reachable:

``` bash
nc -zv 10.0.1.50 3306
```

If the port is not reachable, check:

-   Is MySQL running?
-   Is MySQL listening on port `3306`?
-   Is the server listening on the correct interface?
-   Is a firewall blocking the connection?
-   In AWS, is a security group or network ACL blocking it?
-   Is the application using the correct IP and port?

------------------------------------------------------------------------

# DNS + IP + Subnet + Port: How They Work Together

A useful example is:

``` text
mysql.example.com:3306
```

Here:

``` text
mysql.example.com
        ↓
       DNS
        ↓
    10.0.1.50
        ↓
      subnet
        ↓
       :3306
        ↓
      MySQL
```

Each part answers a different question:

  Part     Question
  -------- ---------------------------------------
  DNS      What IP belongs to this name?
  IP       Which machine should I reach?
  Subnet   Which network does this IP belong to?
  Port     Which service should I connect to?

------------------------------------------------------------------------

# Quick Revision

## DNS

``` text
Domain name → IP address
```

``` text
A      → IPv4
AAAA   → IPv6
CNAME  → Alias
MX     → Mail server
NS     → Name server
```

------------------------------------------------------------------------

## IPv4

``` text
192.168.1.10
```

-   32 bits
-   4 octets
-   Each octet: `0–255`

Private ranges:

``` text
10.0.0.0/8
172.16.0.0/12
192.168.0.0/16
```

------------------------------------------------------------------------

## CIDR

``` text
192.168.1.0/24
```

`/24` means:

``` text
24 network bits
8 host bits
```

Common examples:

``` text
/24 → 256 total → 254 usable
/16 → 65,536 total → 65,534 usable
/28 → 16 total → 14 usable
```

------------------------------------------------------------------------

## Ports

``` text
22    → SSH
80    → HTTP
443   → HTTPS
53    → DNS
3306  → MySQL
6379  → Redis
27017 → MongoDB
```

Remember:

``` text
IP   → Which machine?
Port → Which service?
```

------------------------------------------------------------------------

# 3 Key Things I Learned

### 1. DNS connects names to IP addresses

Humans use names such as:

``` text
google.com
```

while computers use IP addresses to communicate.

### 2. CIDR tells us how a network is divided

For example:

``` text
192.168.1.0/24
```

means 24 bits are used for the network portion and 8 bits remain for
hosts.

### 3. Ports identify services

An IP address tells us which machine to reach, while the port tells us
which service on that machine we want to communicate with.

------------------------------------------------------------------------

# Useful Commands

``` bash
# Show IP addresses
ip addr show

# DNS lookup
dig google.com

# Check listening ports
sudo ss -tulpn

# Test a TCP port
nc -zv <host> <port>

# Check reachability
ping <host>
```

------------------------------------------------------------------------

# Day 15 Complete

**Next:** Continue building networking fundamentals and connect these
concepts with real cloud networking.
