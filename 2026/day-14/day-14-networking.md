# Day 14 -- Networking Fundamentals & Hands-on Checks

## Overview

Networking is a big part of DevOps troubleshooting.

When something is not working, we need to find out where the problem is:

-   Is the machine connected to the network?
-   Can it reach the destination?
-   Can DNS resolve the name?
-   Is the required port open?
-   Is the service running?
-   Is the application responding?

This day focuses on the basic networking concepts and commands used to
answer these questions.

------------------------------------------------------------------------

## 1. OSI Model vs TCP/IP Model

### OSI Model

The OSI model has **7 layers**. It is mainly used as a way to understand
how network communication works.

  -----------------------------------------------------------------------
  Layer             Name              What it does      Examples
  ----------------- ----------------- ----------------- -----------------
  L7                Application       Network services  HTTP, HTTPS, DNS,
                                      used by           SSH
                                      applications      

  L6                Presentation      Data format,      Encryption,
                                      encryption and    encoding
                                      compression       

  L5                Session           Manages           Session
                                      communication     management
                                      sessions          

  L4                Transport         End-to-end        TCP, UDP
                                      communication     

  L3                Network           IP addressing and IP, routers
                                      routing           

  L2                Data Link         Communication on  MAC, Ethernet
                                      the local network 

  L1                Physical          Sends bits        Cables, radio
                                      through the       signals
                                      physical medium   
  -----------------------------------------------------------------------

### Quick view

``` text
L7  Application
L6  Presentation
L5  Session
L4  Transport
L3  Network
L2  Data Link
L1  Physical
```

### OSI vs TCP/IP diagram

Add the OSI/TCP-IP image here. Keep the image in the same folder as this
Markdown file.

![Uploading Screenshot 2026-08-11 at 6.05.10 PM.png…]()

------------------------------------------------------------------------

## 2. TCP/IP Model

The TCP/IP model is simpler and is closer to how networking is actually
implemented.

It has **4 layers**:

  TCP/IP Layer            OSI Layers     Examples
  ----------------------- -------------- -----------------------
  Application             L5 + L6 + L7   HTTP, HTTPS, DNS, SSH
  Transport               L4             TCP, UDP
  Internet                L3             IP, ICMP
  Network Access / Link   L1 + L2        Ethernet, Wi-Fi

### Main difference

The OSI model has 7 separate layers, while TCP/IP combines some of them.

``` text
OSI                         TCP/IP

Application       ┐
Presentation      ├──────>  Application
Session            ┘

Transport         ───────>  Transport

Network           ───────>  Internet

Data Link         ┐
Physical           ├──────>  Network Access / Link
                   ┘
```

So remember:

-   **OSI = 7 layers**
-   **TCP/IP = 4 layers**

------------------------------------------------------------------------

## 3. Where Do IP, TCP/UDP, HTTP/HTTPS and DNS Fit?

A simple way to remember them:

``` text
Application
    HTTP
    HTTPS
    DNS
    SSH
       ↓
Transport
    TCP
    UDP
       ↓
Internet / Network
    IP
       ↓
Network Access / Link
    Ethernet
    Wi-Fi
```

### Important points

-   **IP** → Network / Internet layer
-   **TCP and UDP** → Transport layer
-   **HTTP and HTTPS** → Application layer
-   **DNS** → Application layer
-   **MAC addresses** → Data Link layer

------------------------------------------------------------------------

## 4. Example: `curl https://example.com`

Consider:

``` bash
curl https://example.com
```

A simplified view is:

``` text
curl
 ↓
HTTPS
 ↓
TCP
 ↓
IP
 ↓
Ethernet / Wi-Fi
```

So:

-   **HTTPS** → Application layer
-   **TCP** → Transport layer
-   **IP** → Internet / Network layer
-   **Ethernet / Wi-Fi** → Link / Network Access layer

HTTPS normally uses **TCP port 443**.

Remember:

``` text
HTTPS = protocol
TCP    = transport protocol
443    = port
IP     = addressing / routing
```

A port is not the same thing as a protocol.

------------------------------------------------------------------------

# Hands-on Networking Checks

## 5. Identity -- Find Your IP Address

### Command

``` bash
hostname -I
```

This displays the IP addresses assigned to the machine.

### Example output

``` text
$ hostname -I
192.168.1.20
```

Another useful command is:

``` bash
ip addr show
```

This gives more detailed information about the network interfaces.

### Example output

``` text
$ ip addr show

2: eth0:
    inet 192.168.1.20/24
    inet6 fe80::1234:abcd/64
```

Here:

``` text
192.168.1.20
```

is the IPv4 address of the interface.

### Why is this useful?

If a server cannot communicate with other machines, checking its IP
address is one of the first things to verify.

------------------------------------------------------------------------

## 6. Reachability -- `ping`

### Command

``` bash
ping -c 4 google.com
```

`ping` checks whether a destination can be reached using ICMP.

It also shows the approximate round-trip time.

### Example output

``` text
$ ping -c 4 google.com

PING google.com (142.250.183.14) 56(84) bytes of data.
64 bytes from 142.250.183.14: icmp_seq=1 ttl=117 time=25.4 ms
64 bytes from 142.250.183.14: icmp_seq=2 ttl=117 time=24.8 ms
64 bytes from 142.250.183.14: icmp_seq=3 ttl=117 time=26.1 ms
64 bytes from 142.250.183.14: icmp_seq=4 ttl=117 time=25.0 ms

--- google.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss
round-trip min/avg/max = 24.8/25.3/26.1 ms
```

### What should I look at?

Mainly:

-   **Packet loss**
-   **Latency**

For example:

``` text
0% packet loss
```

means all packets received a response.

The average latency in the example is about **25 ms**.

### Important

A successful ping does **not** mean the application is working.

A server can respond to ping while its web application or required port
is down.

------------------------------------------------------------------------

## 7. Path -- `traceroute`

### Command

``` bash
traceroute google.com
```

`traceroute` shows the network path taken to reach a destination.

### Example output

``` text
$ traceroute google.com

traceroute to google.com (142.250.183.14), 30 hops max

1   192.168.1.1       2.1 ms
2   10.20.0.1         8.4 ms
3   172.16.10.1      15.2 ms
4   203.0.113.1      22.7 ms
5   142.250.183.14   25.1 ms
```

Each number represents a **hop**.

For example:

``` text
1 → local router
2 → next network device
3 → another router
...
```

### What if I see `*`?

Example:

``` text
3   *   *   *
```

This does not automatically mean the network is broken.

A router may simply not respond to traceroute probes.

So:

> A timeout at one hop does not necessarily mean traffic stops there.

Look at whether later hops continue responding.

------------------------------------------------------------------------

## 8. Ports -- Find Listening Services

### Command

``` bash
sudo ss -tulpn
```

`ss` is commonly used to view network sockets and listening services.

The options mean:

  Option   Meaning
  -------- -----------------------------------------
  `-t`     TCP
  `-u`     UDP
  `-l`     Listening
  `-p`     Process
  `-n`     Show numbers instead of resolving names

### Example output

``` text
$ sudo ss -tulpn

Netid State  Local Address:Port  Process
tcp   LISTEN 0.0.0.0:22          users:(("sshd",pid=812,fd=3))
tcp   LISTEN 0.0.0.0:80          users:(("nginx",pid=1024,fd=6))
udp   UNCONN 0.0.0.0:53          users:(("dnsmasq",pid=600,fd=5))
```

From this output:

``` text
22 → SSH
80 → HTTP
53 → DNS
```

### Why is this useful?

Suppose your application should be running on port `8080`.

You can check:

``` bash
sudo ss -tulpn
```

If nothing is listening on `8080`, the service may not be running or may
be configured to use another port.

------------------------------------------------------------------------

## 9. Name Resolution -- DNS

### Command

``` bash
dig google.com
```

DNS converts domain names into IP addresses.

For example:

``` text
google.com
     ↓
    DNS
     ↓
142.250.x.x
```

### Example output

``` text
$ dig google.com

;; ANSWER SECTION:
google.com.     300     IN      A       142.250.183.14
```

Here:

-   `google.com` → domain name
-   `300` → TTL
-   `A` → IPv4 address record
-   `142.250.183.14` → resolved IPv4 address

Another command is:

``` bash
nslookup google.com
```

### Example output

``` text
$ nslookup google.com

Name:    google.com
Address: 142.250.183.14
```

### Why is DNS important?

If:

``` bash
ping 8.8.8.8
```

works but:

``` bash
ping google.com
```

does not work, DNS could be the problem.

------------------------------------------------------------------------

## 10. HTTP Check -- `curl`

### Command

``` bash
curl -I https://example.com
```

The `-I` option asks for the HTTP response headers instead of
downloading the complete page.

### Example output

``` text
$ curl -I https://example.com

HTTP/2 200
content-type: text/html
server: envoy
content-length: 1256
```

The important part is:

``` text
200
```

This is the HTTP status code.

### Common HTTP status codes

  Code   Meaning
  ------ -------------------------
  200    OK / request succeeded
  301    Permanently redirected
  302    Temporarily redirected
  400    Bad request
  401    Authentication required
  403    Forbidden
  404    Not found
  500    Internal server error
  502    Bad gateway
  503    Service unavailable

### Example: Redirect

``` bash
curl -I http://example.com
```

might return:

``` text
HTTP/1.1 301 Moved Permanently
Location: https://example.com/
```

This means the server is telling the client to use another URL.

------------------------------------------------------------------------

## 11. Connections Snapshot

### Command

``` bash
netstat -an | head
```

This gives a quick look at network connections and listening sockets.

### Example output

``` text
$ netstat -an | head

Active Internet connections

Proto Recv-Q Send-Q Local Address      Foreign Address      State
tcp        0      0 0.0.0.0:22         0.0.0.0:*            LISTEN
tcp        0      0 192.168.1.20:22    192.168.1.10:54321   ESTABLISHED
tcp        0      0 192.168.1.20:443   192.168.1.30:51234   ESTABLISHED
```

Two useful states are:

### LISTEN

A service is waiting for incoming connections.

### ESTABLISHED

A connection has already been created between two endpoints.

You can also use `ss` for more specific checks:

``` bash
ss -tan state established
```

To see listening TCP ports:

``` bash
ss -ltn
```

------------------------------------------------------------------------

# Mini Task -- Port Probe

First, identify a listening port:

``` bash
sudo ss -tulpn
```

For example:

``` text
tcp LISTEN 0 128 0.0.0.0:22 0.0.0.0:* users:(("sshd",pid=812))
```

Here SSH is listening on:

``` text
Port 22
```

Now test it:

``` bash
nc -zv localhost 22
```

### Successful output

``` text
Connection to localhost 22 port [tcp/ssh] succeeded!
```

This means something is accepting TCP connections on port 22.

### If it fails

You might see:

``` text
nc: connect to localhost port 22 (tcp) failed: Connection refused
```

The next checks would be:

``` bash
sudo systemctl status ssh
```

and:

``` bash
sudo ss -ltnp | grep :22
```

Then check firewall rules if necessary.

------------------------------------------------------------------------

# What Does "Connection Refused" Mean?

Suppose:

``` bash
nc -zv localhost 8080
```

returns:

``` text
Connection refused
```

It generally means the machine was reachable, but nothing accepted the
connection on that port.

Possible causes:

-   The service is not running.
-   The service is listening on another port.
-   The service is bound to another address.
-   Firewall or network rules are involved.

A simple troubleshooting flow:

``` text
Connection refused
       ↓
Is the service running?
       ↓
Is it listening?
       ↓
Is it listening on the correct port?
       ↓
Is it bound to the correct IP/interface?
       ↓
Check firewall/network rules
```

------------------------------------------------------------------------

# Putting Everything Together

Suppose we run:

``` bash
curl https://example.com
```

Several networking concepts are involved:

``` text
example.com
     ↓
DNS
     ↓
IP address
     ↓
TCP connection
     ↓
Port 443
     ↓
HTTPS
     ↓
HTTP response
```

So one simple command can involve several networking concepts and
layers.

------------------------------------------------------------------------

# Troubleshooting Scenarios

## Scenario 1: DNS is not working

Suppose:

``` bash
curl https://myapp.com
```

fails because the hostname cannot be resolved.

First check DNS:

``` bash
dig myapp.com
```

or:

``` bash
nslookup myapp.com
```

Then check:

-   Is the DNS server reachable?
-   Is the DNS record correct?
-   Is the hostname spelled correctly?
-   Is DNS configured correctly on the machine?

DNS is an **Application-layer protocol**, so start by checking the DNS
configuration and name-resolution path.

------------------------------------------------------------------------

## Scenario 2: HTTP returns 500

Suppose:

``` bash
curl -I https://myapp.com
```

returns:

``` text
HTTP/1.1 500 Internal Server Error
```

This tells us something important:

``` text
DNS worked
    ↓
IP was reached
    ↓
HTTP request reached the server
    ↓
Application/server returned an error
```

So the next checks should usually move toward:

-   Application logs
-   Web server logs
-   Backend/service health
-   Database or other dependency connectivity

A `500` is generally an **application/server-side problem**, not simply
a network connectivity problem.

------------------------------------------------------------------------

# Quick Command Reference

  Problem                          Command
  -------------------------------- ---------------------------
  Find my IP                       `hostname -I`
  Detailed interface information   `ip addr show`
  Check reachability               `ping <host>`
  Check network path               `traceroute <host>`
  Check DNS                        `dig <domain>`
  Alternative DNS check            `nslookup <domain>`
  See listening ports              `sudo ss -tulpn`
  Test a specific TCP port         `nc -zv <host> <port>`
  Check HTTP response              `curl -I <URL>`
  View connections                 `ss -tan` / `netstat -an`

------------------------------------------------------------------------

# Reflection

## Which command gives the fastest signal when something is broken?

Usually, **`ping` is a quick first check for basic reachability**, but
it is not enough by itself.

For an application problem, `curl` or `nc` can give a more useful signal
because they test the actual service or port.

------------------------------------------------------------------------

## What would I inspect if DNS fails?

Start with the **DNS/name-resolution path**:

``` bash
dig <domain>
```

Then check the DNS server, DNS records and local DNS configuration.

------------------------------------------------------------------------

## What would I inspect if HTTP 500 shows up?

A `500` means the request reached the server but the application/server
returned an error.

Next checks:

-   Application logs
-   Web server logs
-   Backend dependencies
-   Database connectivity

------------------------------------------------------------------------

## Two follow-up checks in a real incident

1.  Check whether the required service is running and listening on the
    expected port.

``` bash
sudo systemctl status <service>
sudo ss -ltnp
```

2.  Test connectivity to the required host and port.

``` bash
nc -zv <host> <port>
```

------------------------------------------------------------------------

# Key Takeaways

### 1. Know what each command tells you

``` text
ping        → Can I reach it?
traceroute  → What path does traffic take?
dig         → Does DNS resolve the name?
ss          → What ports/services are listening?
nc          → Can I connect to this port?
curl        → Does the application respond?
```

### 2. IP and port answer different questions

``` text
IP   → Which machine?
Port → Which service?
```

Example:

``` text
10.0.1.50:3306
```

means:

``` text
10.0.1.50 → destination IP
3306      → destination port
```

### 3. Troubleshoot step by step

``` text
Reachability
     ↓
DNS
     ↓
Port
     ↓
Service
     ↓
Application
```

The goal is not just to memorize commands.

The goal is to understand **what question each command answers**.

------------------------------------------------------------------------

## Day 14 Complete

**Next:** Day 15 -- DNS, IP, Subnets & Ports
