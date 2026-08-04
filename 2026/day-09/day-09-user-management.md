# Day 09 – Linux User & Group Management

Done on a fresh Ubuntu 26.04 EC2 instance (t3.micro), since macOS doesn't have `useradd`.

---

## Users & Groups Created

**Users:** `tokyo`, `berlin`, `professor`, `nairobi`
**Groups:** `developers`, `admins`, `project-team`

## Group Assignments

| User | Primary group | Secondary groups |
|---|---|---|
| tokyo | tokyo | developers, project-team |
| berlin | berlin | developers, admins |
| professor | professor | admins |
| nairobi | nairobi | project-team |

Verified with `id`:

```
uid=1001(tokyo) gid=1001(tokyo) groups=1001(tokyo),1004(developers),1007(project-team)
uid=1002(berlin) gid=1002(berlin) groups=1002(berlin),1004(developers),1005(admins)
uid=1003(professor) gid=1003(professor) groups=1003(professor),1005(admins)
```



## Directories Created

| Path | Owner:Group | Mode | Why |
|---|---|---|---|
| `/opt/dev-project` | root:developers | 2775 | setgid so new files inherit the developers group |
| `/opt/team-workspace` | root:project-team | 3775 | setgid + sticky bit |

---

## Task 1 – Create Users

```bash
sudo useradd -m -s /bin/bash tokyo
sudo useradd -m -s /bin/bash berlin
sudo useradd -m -s /bin/bash professor
sudo passwd tokyo      # repeated for berlin and professor
```

- `-m` creates the home directory. Without it the user exists but has nowhere to live.
- `-s /bin/bash` sets a usable login shell. The default is `/bin/sh`.

Verified with `tail -4 /etc/passwd` and `ls -l /home`.

**What went wrong:** my first `useradd` for tokyo got interrupted, and tokyo ended up with `/bin/sh` while the others had bash:

```
tokyo:x:1001:1001::/home/tokyo:/bin/sh
berlin:x:1002:1002::/home/berlin:/bin/bash
```

Fixed without recreating the user:

```bash
sudo usermod -s /bin/bash tokyo
```

<img width="1182" height="829" alt="Screenshot 2026-08-04 at 8 19 26 PM" src="https://github.com/user-attachments/assets/4aa1e1df-f1b8-40d7-9a7e-bcd46a8e0888" />

## Task 2 – Create Groups

```bash
sudo groupadd developers
sudo groupadd admins
getent group developers admins
```

```
developers:x:1004:
admins:x:1005:
```

`getent group` reads the group database properly. `tail /etc/group` also works — but note the file is `/etc/group`, not `/etc/grp`.

## Task 3 – Assign Users to Groups

```bash
sudo gpasswd -a tokyo developers
sudo gpasswd -a berlin developers
sudo gpasswd -a berlin admins
sudo usermod -aG admins professor
```

**What went wrong:** I tried to add berlin to both groups in one `gpasswd` command. Neither of these works:

```bash
sudo gpasswd -a berlin developers admins     # usage error
sudo gpasswd -a berlin developers,admins     # group 'developers,admins' does not exist
```

`gpasswd -a` takes exactly one group. The command that accepts a comma-separated list is:

```bash
sudo usermod -aG developers,admins berlin
```

`-a` means **append**. `usermod -G` without the `-a` replaces every secondary group the user has — that's how people accidentally remove themselves from `sudo` and lock themselves out of a server.

Verified with `id berlin` rather than `groups berlin`, because `id` shows the primary group separately from the secondary ones.

## Task 4 – Shared Directory (the interesting one)

```bash
sudo mkdir /opt/dev-project
sudo chgrp developers /opt/dev-project
sudo chmod 775 /opt/dev-project
sudo -u tokyo touch /opt/dev-project/tokyo-notes.txt
ls -l /opt/dev-project
```

```
-rw-r--r-- 1 tokyo tokyo 0 Aug  4 14:55 tokyo-notes.txt
```

The directory is `775 developers`, but the file inside it landed as **tokyo:tokyo, mode 644**. So:

```bash
sudo -u berlin sh -c 'echo hi >> /opt/dev-project/tokyo-notes.txt'
sh: 1: cannot create /opt/dev-project/tokyo-notes.txt: Permission denied
```

<img width="1448" height="800" alt="Screenshot 2026-08-04 at 8 39 37 PM" src="https://github.com/user-attachments/assets/71c67606-2bf8-4d5e-aff1-a94408ee642f" />


Berlin is in `developers` and can create files in the directory. Berlin still cannot edit tokyo's file. **Directory permissions control who can add and remove entries. They say nothing about the files inside.**

Two things were missing:

```bash
sudo chmod 2775 /opt/dev-project
ls -ld /opt/dev-project
drwxrwsr-x 2 root developers 4096 Aug  4 14:55 /opt/dev-project
```

The leading `2` is the **setgid bit** — the `s` in `drwxrwsr-x`. New files now inherit the directory's group instead of the creator's.

```bash
sudo -u tokyo sh -c 'umask 002; touch /opt/dev-project/shared.txt'
ls -l /opt/dev-project
-rw-rw-r-- 1 tokyo developers 0 Aug  4 14:58 shared.txt
```

`umask` decides the default permissions on new files. Ubuntu's default of `022` strips group write, producing 644. `002` leaves it, producing 664.

setgid fixed **who owns the file**. umask fixed **who can write to it**. Both were needed.

**setgid only applies to new files.** `tokyo-notes.txt` was created before the change and was still broken, so existing files needed fixing separately:

```bash
sudo chgrp -R developers /opt/dev-project
sudo chmod -R g+w /opt/dev-project
sudo -u berlin sh -c 'echo "berlin was here" >> /opt/dev-project/tokyo-notes.txt'
cat /opt/dev-project/tokyo-notes.txt
```


**Side note:** running plain `touch tokyo berlin` inside the directory as the `ubuntu` user also failed. Ubuntu isn't in `developers`, so it falls into the "other" bucket — `5` in `775`, which is read and execute but no write.

## Task 5 – Team Workspace

Same setup, done correctly from the start:

```bash
sudo useradd -m -s /bin/bash nairobi
sudo passwd nairobi
sudo groupadd project-team
sudo usermod -aG project-team nairobi
sudo usermod -aG project-team tokyo
id tokyo

sudo mkdir /opt/team-workspace
sudo chgrp project-team /opt/team-workspace
sudo chmod 2775 /opt/team-workspace

sudo -u nairobi sh -c 'umask 002; touch /opt/team-workspace/nairobi-file.txt'
ls -l /opt/team-workspace
-rw-rw-r-- 1 nairobi project-team 0 Aug  4 15:02 nairobi-file.txt

sudo -u tokyo sh -c 'echo "tokyo was here" >> /opt/team-workspace/nairobi-file.txt'
cat /opt/team-workspace/nairobi-file.txt
```

Tokyo's append worked on the first attempt — which was the point of the exercise. Tokyo is also proof that a user can sit in multiple groups at once (`developers` and `project-team`).

Then added the sticky bit:

```bash
sudo chmod 3775 /opt/team-workspace
ls -ld /opt/team-workspace
drwxrwsr-t 2 root project-team 4096 Aug  4 15:02 /opt/team-workspace
```

The `t` at the end is the sticky bit: members can create files but can only delete their **own**. Tested it:

```bash
sudo -u tokyo rm /opt/team-workspace/nairobi-file.txt
rm: cannot remove '...': Operation not permitted
```


This is the same mechanism `/tmp` uses.

---

## Permission Digit Reference

| Mode | Name | Effect on a shared directory |
|---|---|---|
| `0775` | plain | folder access only; files stay private to whoever made them |
| `2775` | setgid | new files inherit the folder's group |
| `1775` | sticky | you can only delete your own files |
| `3775` | setgid + sticky | what a real team workspace should be |

---

## Commands Used

```bash
# users
useradd -m -s /bin/bash <user>
passwd <user>
usermod -s /bin/bash <user>
userdel -r <user>

# groups
groupadd <group>
getent group <group>
gpasswd -a <user> <group>
usermod -aG <group1>,<group2> <user>
id <user>

# permissions
chgrp <group> <dir>
chgrp -R <group> <dir>
chmod 775 / 2775 / 3775 <dir>
chmod -R g+w <dir>
umask 002
ls -l / ls -ld

# testing as another user
sudo -u <user> <command>
sudo -u <user> sh -c '<command with redirection>'
```

Note: `sudo -u tokyo echo hi >> file` doesn't do what you'd expect — the redirect runs as your own shell, not as tokyo. Wrapping it in `sh -c '...'` is what makes the write actually happen as that user.

---

## What I Learned

1. **`775` is not enough for a shared folder.** The directory mode controls who can add and delete entries; each file inside still carries its own owner and mode. Two teammates in the same group could both create files and still not be able to edit each other's work. `2775` plus `umask 002` is what makes a shared directory behave the way people assume it already does.

2. **setgid is not retroactive.** It only affects files created after it's set. Anything already sitting in the directory needs `chgrp -R` and `chmod -R g+w`. On a real server you almost always inherit files that predate your fix.

3. **`-a` matters more than anything else in `usermod`.** `usermod -aG` appends; `usermod -G` silently replaces every secondary group. Dropping the `-a` on your own account is a good way to remove yourself from `sudo` and lose access to the box.

---

## Cleanup

```bash
sudo userdel -r tokyo
sudo userdel -r berlin
sudo userdel -r professor
sudo userdel -r nairobi
sudo rm -rf /opt/dev-project /opt/team-workspace
```

EC2 instance terminated afterwards.

---

Part of the #90DaysOfDevOps challenge — #DevOpsKaJosh #TrainWithShubham
