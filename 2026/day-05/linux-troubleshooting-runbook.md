# Linux Troubleshooting Runbook — mysqld

Day 05 of #90DaysOfDevOps.

Target: **mysqld** (MySQL Community Server 9.5.0) — a service I found
running on my machine during Day 4's audit and decided to investigate
properly. Machine is a Mac (Darwin arm64), so a few commands are the
macOS equivalents the task suggests (`vm_stat`, `log show`).

Every output below is real, from my machine.

---

## Environment basics

```
$ uname -a
Darwin ... 25.5.0 ... RELEASE_ARM64_T8132 arm64
$ sw_vers
macOS 26.5.1 (25F80)
```
Note: always capture this first — "what OS/arch am I on" decides which
commands and paths apply for everything after it.

## Filesystem sanity

```
$ mkdir -p /tmp/runbook-demo && cp /etc/hosts /tmp/runbook-demo/hosts-copy && ls -l /tmp/runbook-demo
-rw-r--r--  1 snigdha  wheel  213 31 Jul 11:39 hosts-copy
```
Note: can I create and copy files? Yes — rules out a full/read-only
disk before I trust anything else.

## Snapshot: CPU & Memory

```
$ ps -o pid,pcpu,pmem,etime,comm -p $(pgrep -x mysqld)
  PID  %CPU %MEM ELAPSED COMM
  562   0.2  2.3   19:11 /usr/local/mysql/bin/mysqld
$ vm_stat | head -8
Pages free: 7309.   Pages active: 421880.   Pages wired down: 130327. ...
```
Notes: mysqld is idle — 0.2% CPU, 2.3% memory, up 19 minutes (since
boot). Yesterday its PID was 573, today 562: PIDs change across
restarts, which is why runbooks track services by name/label, never by
PID. vm_stat shows low free pages but that's normal on macOS — unused
RAM gets used as cache.

## Snapshot: Disk & IO

```
$ df -h /
/dev/disk3s1s1   228Gi   12Gi   18Gi   40%   /
$ sudo du -sh /usr/local/mysql/data
201M    /usr/local/mysql/data
$ iostat
    KB/t  tps  MB/s  us sy id   1m   5m   15m
   20.65  852 17.18  25 11 64  1.65 5.07 6.98
```
Notes: MySQL's data is a modest 201M — not a disk risk itself. But
only **18Gi available on the whole disk**, which is a genuine
watch-item (below ~10% free, machines misbehave). Load averages
falling from 6.98 → 1.65 tell a story: heavy work during boot,
settling now.

## Snapshot: Network

```
$ lsof -i :3306
(empty)
$ nc -vz localhost 3306
Connection to localhost port 3306 [tcp/mysql] succeeded!
$ sudo lsof -i :3306
mysqld  562 _mysql ... TCP *:mysql (LISTEN)
```
Notes: the contradiction was the lesson. Plain lsof showed nothing,
but nc proved the port answers — because without sudo, lsof only
shows processes *you* own, and mysqld runs as `_mysql`. "Empty
output" meant "wrong permissions", not "port free".

**Finding:** mysqld listens on `*:3306` — all interfaces, not just
localhost. The log also shows an X Plugin on port 33060, bind-address
`::` (all interfaces again). On shared Wi-Fi this exposes the database
port to the network. It has auth and the macOS firewall in front of
it, but it should still be bound to 127.0.0.1 on a laptop.

## Logs reviewed

```
$ log show --last 5m --predicate 'process == "mysqld"' | tail -5
(empty)
$ sudo ls -lh /usr/local/mysql/data/ | grep -i err
-rw-r-----  1 _mysql  _mysql  452K 31 Jul 11:20 mysqld.local.err
$ sudo tail -n 15 /usr/local/mysql/data/mysqld.local.err
2026-07-30T17:50:48Z ... Received SHUTDOWN from user <via user signal>.
2026-07-31T05:50:35Z ... MySQL Server - start.
2026-07-31T05:50:36Z ... starting as process 562
2026-07-31T05:50:38Z ... InnoDB initialization has ended.
2026-07-31T05:50:38Z ... X Plugin ready ... Bind-address: '::' port: 33060
2026-07-31T05:50:38Z ... ready for connections. Version: '9.5.0' port: 3306
```
Notes: the OS unified log had nothing for mysqld — MySQL writes its
own file, `mysqld.local.err` in its data directory. Not every service
logs where the OS logs; the runbook's job is to record *where*. The
log shows a clean shutdown last night, clean 2-second startup at
today's boot, and two ignorable warnings (case-insensitive filesystem,
self-signed cert). Healthy service.

## Quick findings

1. mysqld is healthy and idle: clean start/stop history, near-zero
   CPU, 201M of data, fast InnoDB init.
2. It is listening on **all interfaces** (3306 and 33060) — should be
   localhost-only on a laptop. This is the actionable finding.
3. Disk: 18Gi available system-wide — worth watching, unrelated to
   MySQL.
4. Two tool gotchas that would cost real time in an incident: lsof
   needs sudo to see other users' sockets, and MySQL bypasses the
   system log entirely.

## If this worsens (next steps)

1. **Exposure:** add `bind_address=127.0.0.1` (and
   `mysqlx_bind_address=127.0.0.1`) to my.cnf and restart via the
   supervisor — or, if I confirm nothing on this machine uses MySQL,
   decommission it properly like the Day 4 services: stop via
   launchd, then uninstall. Never just `kill` a supervised service.
2. **Disk:** if Avail drops toward 10Gi — `du -sh` the big
   directories, clear caches/old projects; a full disk takes MySQL
   and everything else down with it.
3. **If CPU/memory ever spikes:** capture evidence *before*
   restarting — `ps` snapshot, `SHOW PROCESSLIST` inside MySQL to see
   the running queries, and tail the error log. Restart is the last
   step, not the first, and it goes through the supervisor so the
   evidence (logs) survives.

---

The habit this drill builds: snapshot → interpret → only then act.
Every command here took seconds; knowing which output is normal and
which isn't is the actual skill.
