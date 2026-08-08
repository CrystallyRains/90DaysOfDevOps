# Day 11 - Linux File Ownership (chown & chgrp)

## Objective

The goal of today's challenge was to understand Linux file ownership, learn the difference between users and groups, and practice changing ownership using `chown` and `chgrp`.

---

# Understanding File Ownership

Every file and directory in Linux has:

- **Owner** – The user who owns the file.
- **Group** – A group of users who may share access to the file.

To view ownership information:

```bash
ls -l
```

Example output:

```text
-rw-rw-r-- 1 ubuntu ubuntu 0 Aug 5 16:25 devops-file.txt
```

Explanation:

| Field | Value | Meaning |
|-------|-------|---------|
| Permissions | `-rw-rw-r--` | File permissions |
| Owner | `ubuntu` | User who owns the file |
| Group | `ubuntu` | Group assigned to the file |
| Filename | `devops-file.txt` | File name |

### Owner vs Group

- **Owner** is the user who has ownership of the file.
- **Group** allows multiple users in the same group to share access based on the assigned permissions.

---

# Task 1 – Basic `chown` Operations

## Create a file

```bash
touch devops-file.txt
```

Check the current owner:

```bash
ls -l devops-file.txt
```

Output:

```text
-rw-rw-r-- 1 ubuntu ubuntu 0 Aug 5 16:25 devops-file.txt
```

---

## Create a new user

```bash
sudo useradd -m tokyo
sudo passwd tokyo
```

---

## Attempt to change ownership without sudo

```bash
chown tokyo devops-file.txt
```

Result:

```text
chown: changing ownership of 'devops-file.txt': Operation not permitted
```

**Why?**

Changing the owner of a file requires administrative privileges, so `sudo` must be used.

---

## Change owner to tokyo

```bash
sudo chown tokyo devops-file.txt
```

Verify:

```bash
ls -l devops-file.txt
```

Output:

```text
-rw-rw-r-- 1 tokyo ubuntu 0 Aug 5 16:25 devops-file.txt
```

---

## Change owner to berlin

Create another user:

```bash
sudo useradd -m berlin
```

Change ownership:

```bash
sudo chown berlin devops-file.txt
```

Verify:

```bash
ls -l devops-file.txt
```

Output:

```text
-rw-rw-r-- 1 berlin ubuntu 0 Aug 5 16:25 devops-file.txt
```

---

# Task 2 – Basic `chgrp` Operations

Create a file:

```bash
touch team-notes.txt
```

Check the current group:

```bash
ls -l team-notes.txt
```

Output:

```text
-rw-rw-r-- 1 ubuntu ubuntu 0 Aug 5 16:28 team-notes.txt
```

Create a group:

```bash
sudo groupadd heist-team
```

Change the group:

```bash
sudo chgrp heist-team team-notes.txt
```

Verify:

```bash
ls -l team-notes.txt
```

Output:

```text
-rw-rw-r-- 1 ubuntu heist-team 0 Aug 5 16:28 team-notes.txt
```

---

# Task 3 – Change Owner and Group Together

Create a configuration file:

```bash
touch project-config.yaml
```

Create a user:

```bash
sudo useradd professor
```

Change both owner and group:

```bash
sudo chown professor:heist-team project-config.yaml
```

Verify:

```bash
ls -l project-config.yaml
```

Output:

```text
-rw-rw-r-- 1 professor heist-team 0 Aug 5 16:29 project-config.yaml
```

---

## Change ownership of a directory

Create a directory:

```bash
mkdir app-logs
```

Change both owner and group:

```bash
sudo chown berlin:heist-team app-logs
```

Verify:

```bash
ls -la app-logs
```

Output:

```text
drwxrwxr-x 2 berlin heist-team 4096 Aug 5 16:31 .
drwxr-x--- 5 ubuntu ubuntu      4096 Aug 5 16:31 ..
```

---

# Task 4 – Recursive Ownership

Create the directory structure:

```bash
mkdir -p heist-project/vault
mkdir -p heist-project/plans

touch heist-project/vault/gold.txt
touch heist-project/plans/strategy.conf
```

Create a group:

```bash
sudo groupadd planners
```

Change ownership recursively:

```bash
sudo chown -R professor:planners heist-project/
```

Verify:

```bash
ls -lR heist-project/
```

Output:

```text
heist-project/:
drwxrwxr-x 2 professor planners plans
drwxrwxr-x 2 professor planners vault

heist-project/plans:
-rw-rw-r-- 1 professor planners strategy.conf

heist-project/vault:
-rw-rw-r-- 1 professor planners gold.txt
```

**What does `-R` do?**

The `-R` (recursive) option changes the owner and group of the directory **and everything inside it**, including all files and subdirectories.

---

# Task 5 – Practice Challenge

Create users:

```bash
sudo useradd -m nairobi
```

Create groups:

```bash
sudo groupadd vault-team
sudo groupadd tech-team
```

Create a directory:

```bash
mkdir bank-heist
```

Create files:

```bash
touch bank-heist/access-codes.txt
touch bank-heist/blueprints.pdf
touch bank-heist/escape-plan.txt
```

Assign ownership:

```bash
sudo chown tokyo:vault-team bank-heist/access-codes.txt

sudo chown berlin:tech-team bank-heist/blueprints.pdf

sudo chown nairobi:vault-team bank-heist/escape-plan.txt
```

Verify:

```bash
ls -l bank-heist/
```

Output:

```text
-rw-rw-r-- 1 tokyo   vault-team 0 Aug 5 16:35 access-codes.txt
-rw-rw-r-- 1 berlin  tech-team  0 Aug 5 16:35 blueprints.pdf
-rw-rw-r-- 1 nairobi vault-team 0 Aug 5 16:35 escape-plan.txt
```

---

# Commands Used

```bash
ls -l
ls -la
ls -lR

touch

useradd
passwd
userdel

groupadd

chown
chown -R

chgrp

mkdir
```

---

# Troubleshooting

## Error 1 – Operation not permitted

```bash
chown tokyo devops-file.txt
```

Output:

```text
Operation not permitted
```

**Reason:**

Changing file ownership requires administrative privileges.

**Solution:**

```bash
sudo chown tokyo devops-file.txt
```

---

## Error 2 – User already exists

```text
useradd: user 'nairobi' already exists
```

**Reason:**

The user had already been created earlier.

---

## Error 3 – No such file or directory

While inside the `bank-heist` directory, I ran:

```bash
ls -l bank-heist/
```

Output:

```text
No such file or directory
```

**Reason:**

I was already inside the `bank-heist` directory. After returning to the parent directory using `cd ..`, the command worked as expected.

---

# Key Learnings

- Every Linux file and directory has an associated owner and group.
- `chown` changes the file owner, while `chgrp` changes only the group.
- `chown owner:group` allows changing both the owner and group in a single command.
- Recursive ownership changes can be applied to an entire directory using the `-R` option.
- Using `ls -l` and `ls -lR` is the easiest way to verify ownership changes after running `chown` or `chgrp`.
