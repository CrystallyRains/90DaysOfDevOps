# Day 09 – Linux User & Group Management

---

# Users & Groups Created

### Users

- tokyo
- berlin
- professor
- nairobi

### Groups

- developers
- admins
- project-team

---

# Group Assignments

| User | Primary Group | Secondary Groups |
|------|---------------|------------------|
| tokyo | tokyo | developers, project-team |
| berlin | berlin | developers, admins |
| professor | professor | admins |
| nairobi | nairobi | project-team |

Verified using:

```bash
id username
```

Example:

```text
uid=1001(tokyo) gid=1001(tokyo) groups=1001(tokyo),1004(developers),1007(project-team)
```

The `id` command shows:

- User ID (UID)
- Primary group
- Secondary groups

It's one of the quickest ways to verify that a user has been added to the correct groups.

---

# Task 1 – Create Users

Create the users:

```bash
sudo useradd -m -s /bin/bash tokyo
sudo useradd -m -s /bin/bash berlin
sudo useradd -m -s /bin/bash professor
```

Set passwords:

```bash
sudo passwd tokyo
```

(Repeat for the remaining users.)

### Understanding the command

```bash
sudo useradd -m -s /bin/bash tokyo
```

- `sudo` → Run as administrator.
- `useradd` → Create a new user.
- `-m` → Create the user's home directory (`/home/tokyo`).
- `-s /bin/bash` → Set Bash as the default login shell.

Without `-m`, the user is created but no home directory is made.

### Verify

```bash
tail -4 /etc/passwd
```

or

```bash
ls -l /home
```

Both confirm that the users were created successfully.

---

## Problem I Faced

While creating `tokyo`, the command got interrupted.

Checking `/etc/passwd` showed:

```text
tokyo:x:1001:1001::/home/tokyo:/bin/sh
berlin:x:1002:1002::/home/berlin:/bin/bash
```

Tokyo was using `/bin/sh` instead of Bash.

Instead of deleting and recreating the user, I simply changed the shell:

```bash
sudo usermod -s /bin/bash tokyo
```

`usermod` modifies an existing user, and the `-s` option changes the login shell.

---

# Task 2 – Create Groups

Create the required groups:

```bash
sudo groupadd developers
sudo groupadd admins
sudo groupadd project-team
```

### What is a group?

A group lets multiple users share the same permissions.

For example:

```text
developers
├── tokyo
└── berlin
```

Instead of giving permissions to each user individually, you can simply give permissions to the **developers** group.

### Verify

```bash
getent group developers admins project-team
```

`getent` reads Linux's user and group database and confirms that the groups exist.

---

# Task 3 – Add Users to Groups

```bash
sudo gpasswd -a tokyo developers
sudo gpasswd -a berlin developers
sudo gpasswd -a berlin admins
sudo usermod -aG admins professor
```

### Understanding the commands

`gpasswd -a`

```bash
gpasswd -a tokyo developers
```

adds **one user** to **one group**.

If you need to add a user to multiple groups at once, use:

```bash
sudo usermod -aG developers,admins berlin
```

### Problem I Faced

I tried:

```bash
sudo gpasswd -a berlin developers admins
```

and

```bash
sudo gpasswd -a berlin developers,admins
```

Both failed.

That's because `gpasswd -a` accepts only **one group**.

---

### Why is `-a` Important?

Correct:

```bash
usermod -aG developers berlin
```

Wrong:

```bash
usermod -G developers berlin
```

The `-a` stands for **append**.

Without it, Linux removes the user from every existing secondary group and keeps only the groups you specify.

That's why forgetting `-a` can accidentally remove a user from important groups like `sudo`.

### Verify

```bash
id berlin
```

This clearly shows both the primary and secondary groups.

---

# Task 4 – Create a Shared Directory

## Goal

The challenge asks us to create a shared directory for members of the **developers** group.

The required steps were:

```bash
sudo mkdir /opt/dev-project
sudo chgrp developers /opt/dev-project
sudo chmod 775 /opt/dev-project
```

Let's understand what each command does.

---

## Step 1 – Create the Directory

```bash
sudo mkdir /opt/dev-project
```

`mkdir` creates a new directory.

At this point the directory belongs to:

```text
Owner : root
Group : root
```

---

## Step 2 – Change the Group

```bash
sudo chgrp developers /opt/dev-project
```

`chgrp` stands for **change group**.

Every file and directory in Linux has:

- an owner
- a group

After running the command:

```text
Owner : root
Group : developers
```

Now members of the **developers** group can access the directory (provided the permissions allow it).

---

## Step 3 – Set Directory Permissions

```bash
sudo chmod 775 /opt/dev-project
```

`chmod` stands for **change mode**, which means changing permissions.

Breaking down `775`:

| Number | Permission |
|---------|------------|
|7|Read + Write + Execute|
|7|Read + Write + Execute|
|5|Read + Execute|

Which means:

```text
Owner  → rwx
Group  → rwx
Others → r-x
```

For **directories**, these permissions mean:

| Permission | Meaning |
|------------|---------|
|Read (`r`)|View the directory contents|
|Write (`w`)|Create, rename and delete files inside the directory|
|Execute (`x`)|Enter (access) the directory|

At this point, everything looked correct.

The directory belonged to the **developers** group and both Tokyo and Berlin were members of that group.

So I expected both users to be able to work together without any issues.

To test it, Tokyo created a file:

```bash
sudo -u tokyo touch /opt/dev-project/tokyo-notes.txt
```

The file looked like this:

```text
-rw-r--r-- 1 tokyo tokyo 0 Aug 4 14:55 tokyo-notes.txt
```

Then Berlin tried to edit it:

```bash
sudo -u berlin sh -c 'echo "Hello" >> /opt/dev-project/tokyo-notes.txt'
```

Instead of working, Linux returned:

```text
Permission denied
```

At first, this didn't make sense.

Both users belonged to the **developers** group.

So why couldn't Berlin edit Tokyo's file?

---

## Why Did It Fail?

The important thing to understand is:

> **Directory permissions and file permissions are separate.**

The directory controls whether you can:

- Enter the directory
- Create new files
- Rename or delete files inside it

But every file inside the directory has its **own**:

- Owner
- Group
- Permissions

Tokyo's file looked like this:

```text
Owner : tokyo
Group : tokyo
Permission : 644
```

Even though the directory belonged to the **developers** group, the file did not.

So when Berlin tried to edit it, Linux checked **the file's permissions**, not just the directory's permissions.

That's why the operation failed.

> 💡 **Key takeaway**
>
> `775` lets users share the **directory**, but it doesn't automatically make the files inside editable by everyone in the group.

---

## Making the Directory Truly Shared

To make collaboration work properly, two things were missing:

1. New files should automatically belong to the **developers** group.
2. Members of the **developers** group should be able to edit those files.

### Step 1 – Enable setgid

```bash
sudo chmod 2775 /opt/dev-project
```

Notice the extra **2** at the beginning.

This enables the **setgid** bit.

Normally, when someone creates a file:

```text
Tokyo creates a file
        ↓
Group = tokyo
```

With **setgid** enabled:

```text
Tokyo creates a file
        ↓
Group = developers
```

Instead of using the creator's primary group, Linux automatically uses the directory's group.

This keeps every new file in the shared directory under the same group.

> 💡 **Easy way to remember**
>
> - Without setgid → **Creator decides the group**
> - With setgid → **Folder decides the group**

Verify it:

```bash
ls -ld /opt/dev-project
```

Output:

```text
drwxrwsr-x
```

The **`s`** in the group section shows that **setgid** is enabled.

---

## Step 2 – Fix Default File Permissions

Even after enabling setgid, there was still one problem.

New files still had permissions like:

```text
-rw-r--r--
```

or

```text
644
```

This means:

| Owner | Group | Others |
|-------|-------|--------|
|Read + Write|Read only|Read only|

The group could read the file but couldn't edit it.

### Why?

Linux creates every new file using a default permission rule called **umask**.

Ubuntu's default is usually:

```bash
umask 022
```

This results in new files being created with permission **644**.

For a shared project folder, I wanted the group to have write access too.

So I used:

```bash
umask 002
```

Now new files are created with:

```text
664
```

which means:

| Owner | Group | Others |
|-------|-------|--------|
|Read + Write|Read + Write|Read only|

Now everyone in the **developers** group can edit newly created files.

> 💡 **Remember**
>
> `umask` doesn't add permissions.
>
> It **removes** permissions from Linux's default values.

---

## What About Existing Files?

There's one important thing to remember.

**setgid only affects new files.**

Anything created before enabling it stays exactly the same.

So existing files had to be fixed manually.

### Change the Group

```bash
sudo chgrp -R developers /opt/dev-project
```

Breaking it down:

- `chgrp` → Change the group owner.
- `-R` → Recursive (apply to everything inside the directory).

Now all files belonged to the **developers** group.

---

### Give the Group Write Permission

```bash
sudo chmod -R g+w /opt/dev-project
```

Breaking it down:

- `g` → Group
- `+` → Add
- `w` → Write permission
- `-R` → Apply the change to every file and subdirectory.

After these changes, Berlin could successfully edit Tokyo's file.

---

# Task 5 – Team Workspace

I repeated the same setup for another shared directory.

```bash
sudo mkdir /opt/team-workspace
sudo chgrp project-team /opt/team-workspace
sudo chmod 2775 /opt/team-workspace
```

This time, **setgid** was enabled from the beginning, so every new file automatically inherited the **project-team** group.

Tokyo was able to edit Nairobi's file without any extra fixes.

---

## Sticky Bit

Finally, I enabled the sticky bit.

```bash
sudo chmod 3775 /opt/team-workspace
```

Here:

- `2` = setgid
- `1` = sticky bit

Together they become:

```text
3775
```

The sticky bit prevents users from deleting each other's files.

Example:

```text
Tokyo creates report.txt

Berlin creates notes.txt

Tokyo ❌ Cannot delete notes.txt

Berlin ✅ Can delete notes.txt
```

This is the same behaviour used by Linux's `/tmp` directory.

Verify:

```bash
ls -ld /opt/team-workspace
```

Output:

```text
drwxrwsr-t
```

The **`t`** at the end indicates that the sticky bit is enabled.

---

# Permission Cheat Sheet

| Permission | Meaning |
|------------|---------|
|`775`|Normal shared directory|
|`2775`|setgid enabled – new files inherit the directory's group|
|`1775`|Sticky bit enabled – users can only delete their own files|
|`3775`|setgid + sticky bit (recommended for shared team workspaces)|

---

# Commands Used

### User Management

```bash
useradd -m -s /bin/bash <user>
passwd <user>
usermod -s /bin/bash <user>
userdel -r <user>
```

### Group Management

```bash
groupadd <group>
gpasswd -a <user> <group>
usermod -aG <group1>,<group2> <user>
id <user>
```

### Permissions

```bash
mkdir
chgrp
chmod
umask
ls -l
ls -ld
```

### Run Commands as Another User

```bash
sudo -u <user> <command>
```

If the command contains `>` or `>>`, use:

```bash
sudo -u <user> sh -c '<command>'
```

Otherwise, the redirection is performed by your current shell instead of the target user.

---

# What I Learned

1. **Directory permissions and file permissions are different.** A shared directory doesn't automatically make every file inside editable.

2. **setgid makes collaboration easier.** Every new file inherits the directory's group instead of the creator's primary group.

3. **umask controls default permissions.** Using `002` allows members of the same group to edit newly created files.

4. **setgid is not retroactive.** Existing files must be updated using `chgrp -R` and `chmod -R g+w`.

5. **Always use `usermod -aG`.** Forgetting `-a` replaces the user's existing secondary groups.

---

# Cleanup

```bash
sudo userdel -r tokyo
sudo userdel -r berlin
sudo userdel -r professor
sudo userdel -r nairobi

sudo rm -rf /opt/dev-project
sudo rm -rf /opt/team-workspace
```

---

Part of the **#90DaysOfDevOps** challenge 🚀  
**#DevOpsKaJosh #TrainWithShubham**
