# Day 10 - Linux File Permissions & File Operations

## Objective

The goal of today's challenge was to understand Linux file permissions, create and read files, modify permissions using `chmod`, and observe how permission changes affect file access and execution.

---

# Task 1 – Creating Files

### 1. Created an empty file

```bash
touch devops.txt
```

### 2. Created a text file with content

```bash
echo "Linux file permissions" > notes.txt
```

### 3. Created a shell script

```bash
vim script.sh
```

Content:

```bash
echo "Hello DevOps"
```

### 4. Verified the files

```bash
ls -l devops.txt notes.txt script.sh
```

Output:

```text
-r--r--r--  1 snigdha  staff   7  Aug 5 20:30 devops.txt
-rw-r-----  1 snigdha  staff  22  Aug 5 20:19 notes.txt
-rwxr-xr-x  1 snigdha  staff  20  Aug 5 20:22 script.sh
```

---

# Task 2 – Reading Files

### Read the contents of `devops.txt`

```bash
cat devops.txt
```

Output:

```text
susush
```

### Display the first five lines of `/etc/passwd`

```bash
head -n 5 /etc/passwd
```

### Display the last five lines

```bash
tail -n 5 /etc/passwd
```

### Open the script in read-only mode

```bash
vim -R script.sh
```

---

# Task 3 – Understanding Linux Permissions

Linux permissions are represented using:

```text
rwxrwxrwx
│ │ │
│ │ └── Others
│ └──── Group
└────── Owner
```

| Symbol | Meaning | Value |
|---------|---------|------:|
| r | Read | 4 |
| w | Write | 2 |
| x | Execute | 1 |

Current permissions:

| File | Permissions | Meaning |
|------|-------------|---------|
| devops.txt | `r--r--r--` | Everyone can read; no one can write or execute |
| notes.txt | `rw-r-----` | Owner can read/write, group can read, others have no access |
| script.sh | `rwxr-xr-x` | Owner has full access; group and others can read and execute |

---

# Task 4 – Modifying Permissions

## Made the script non-executable

```bash
chmod 444 script.sh
```

Tried to execute it:

```bash
./script.sh
```

Result:

```text
zsh: permission denied: ./script.sh
```

---

## Restored execute permission

```bash
chmod +x script.sh
```

Executed again:

```bash
./script.sh
```

Output:

```text
Hello DevOps
```

---

## Removed write permission from `devops.txt`

```bash
chmod -w devops.txt
```

Permissions became:

```text
-r--r--r--
```

---

## Experimented with removing read permission

```bash
chmod -r devops.txt
```

Permissions became:

```text
----------
```

This removed the read permission, leaving the file inaccessible.

---

## Added write and execute permissions

```bash
chmod +wx devops.txt
```

Permissions:

```text
--wx--x--x
```

---

## Restored read permission

```bash
chmod +r devops.txt
```

Permissions:

```text
-rwxr-xr-x
```

---

## Set the file using numeric notation

```bash
chmod 755 devops.txt
```

Permissions:

```text
-rwxr-xr-x
```

---

## Created a directory

```bash
mkdir projects
chmod 755 projects
```

Verified:

```bash
ls -la projects
```

Output:

```text
drwxr-xr-x   2 snigdha  staff    64 Aug 5 20:27 .
drwx------@ 48 snigdha  staff 1536 Aug 5 20:27 ..
```

---

# Task 5 – Testing Permissions

## Executing a file without execute permission

After changing the script permissions to `444`:

```bash
./script.sh
```

Result:

```text
zsh: permission denied: ./script.sh
```

Once execute permission was restored using:

```bash
chmod +x script.sh
```

The script executed successfully:

```text
Hello DevOps
```

---

# Commands Used

```bash
touch
echo
cat
vim
vim -R
head
tail
ls
ls -l
ls -la
chmod
mkdir
./script.sh
```

---

# Key Learnings

- Linux permissions determine who can read, write, and execute files.
- The `chmod` command can modify permissions using symbolic (`+x`, `-w`) or numeric (`755`, `444`) notation.
- A shell script requires execute (`x`) permission before it can be run.
- Removing permissions incorrectly can make a file inaccessible, which helped me understand how each permission affects file access.
- Directory permissions control whether users can access and list directory contents.
