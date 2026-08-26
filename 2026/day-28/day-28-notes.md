# Day 28 – Revision Notes

## 1. Self-Assessment

Day 28 was a revision day covering everything from Day 1 to Day 27.

I went through the checklist and found that I am comfortable with the topics covered so far. I can perform the practical tasks and explain the main concepts.

### Linux

* [x] Navigate the file system, create/move/delete files and directories
* [x] Manage processes — list, kill, background/foreground
* [x] Work with systemd — start, stop, enable, check status of services
* [x] Read and edit text files using vi/vim or nano
* [x] Troubleshoot CPU, memory, and disk issues using top, free, df, and du
* [x] Explain the Linux file system hierarchy
* [x] Create users and groups, and manage passwords
* [x] Set file permissions using chmod
* [x] Change file ownership using chown and chgrp
* [x] Create and manage LVM volumes
* [x] Check network connectivity using ping, curl, ss, dig, and nslookup
* [x] Explain DNS resolution, IP addressing, subnets, and common ports

### Shell Scripting

* [x] Write scripts using variables, arguments, and user input
* [x] Use if/elif/else and case statements
* [x] Write for, while, and until loops
* [x] Define and use functions
* [x] Use grep, awk, sed, sort, and uniq
* [x] Handle errors using set -e, set -u, set -o pipefail, and trap
* [x] Schedule scripts using crontab

### Git & GitHub

* [x] Initialize repositories, stage, commit, and view history
* [x] Create and switch branches
* [x] Push to and pull from GitHub
* [x] Explain clone vs fork
* [x] Merge branches and understand fast-forward vs merge commit
* [x] Rebase branches
* [x] Use git stash and git stash pop
* [x] Cherry-pick commits
* [x] Explain squash merge vs regular merge
* [x] Use git reset and git revert
* [x] Explain GitFlow, GitHub Flow, and Trunk-Based Development
* [x] Use GitHub CLI to work with repositories, pull requests, and issues

---

## 2. Topics I Revisited

I did not find any major gaps in the topics covered so far. However, while answering the quick-fire questions, I noticed a few concepts where I understood the idea but needed to make my technical explanation more precise.

### Process vs Service

A process is a running instance of a program.

For example, when Chrome is opened, multiple Chrome processes may be running at the same time.

A service is a background application that provides a specific function and is generally managed by a service manager such as systemd. A service may continue running in the background instead of simply completing one task and stopping.

In simple terms:

* **Process:** A running instance of a program
* **Service:** A managed background application that provides a specific function

---

### Git Reset vs Git Revert

Both can be used when we want to undo changes, but they work differently.

`git reset` moves the branch to another commit. With `--hard`, it also makes the working directory and staging area match that commit, which can discard uncommitted changes.

`git revert` does not remove the existing commit from history. Instead, it creates a new commit that reverses the changes made by the previous commit.

In simple terms:

* **reset:** Move the branch backward
* **revert:** Create a new commit that undoes an earlier commit

This is why `git revert` is generally safer when working with shared branches such as `main`.

---

### LVM

LVM stands for Logical Volume Manager.

The basic structure is:

```text
Physical Disk
     ↓
Physical Volume (PV)
     ↓
Volume Group (VG)
     ↓
Logical Volume (LV)
```

LVM allows physical storage to be managed through flexible logical volumes.

One of its main advantages is that logical volumes can be resized and managed more flexibly compared with traditional fixed partitions.

---

## 3. Quick-Fire Questions

### 1. What does `chmod 755 script.sh` do?

`chmod 755 script.sh` gives:

* Owner → read, write, execute
* Group → read, execute
* Others → read, execute

So the owner has full permissions, while everyone else can read and execute the file but cannot modify it.

---

### 2. What is the difference between a process and a service?

A process is a running instance of a program.

For example, opening Chrome can result in multiple Chrome processes.

A service is a background application that provides a specific function and is usually managed by a service manager such as systemd.

---

### 3. How do you find which process is using port 8080?

One way is:

```bash
sudo ss -tulpn | grep :8080
```

Another useful command is:

```bash
sudo lsof -i :8080
```

These commands can help identify the process using port 8080.

---

### 4. What does `set -euo pipefail` do in a shell script?

It enables stricter error handling in a Bash script.

* `-e` → exits the script when a command fails
* `-u` → throws an error when an unset variable is used
* `pipefail` → causes a pipeline to fail if any command in the pipeline fails

Together, they make scripts more reliable and help prevent errors from being silently ignored.

---

### 5. What is the difference between `git reset --hard` and `git revert`?

`git reset --hard` moves the current branch to another commit and updates the working directory and staging area to match that commit. It can discard uncommitted changes.

`git revert` creates a new commit that reverses the changes introduced by an earlier commit while keeping the existing commit history.

---

### 6. What branching strategy would you recommend for a team of 5 developers shipping weekly?

I would recommend **GitHub Flow**.

Developers can create feature branches from `main`, make their changes, test them, and create pull requests.

After code review and successful checks, the pull request can be merged into `main`.

This keeps the workflow simple and works well for a small team releasing frequently.

---

### 7. What does `git stash` do and when would you use it?

`git stash` temporarily stores uncommitted changes so that I can switch branches or work on something else without committing unfinished work.

For example:

```bash
git stash
git switch main
```

Later, I can bring the changes back using:

```bash
git stash pop
```

I would use it when I need to temporarily put aside unfinished work.

---

### 8. How do you schedule a script to run every day at 3 AM?

Using crontab:

```cron
0 3 * * * /path/to/script.sh
```

The first five fields represent:

```text
0  → minute
3  → hour
*  → every day of the month
*  → every month
*  → every day of the week
```

So the script runs every day at 3:00 AM.

---

### 9. What is the difference between `git fetch` and `git pull`?

`git fetch` downloads the latest changes from the remote repository but does not change my current branch.

`git pull` downloads the changes and then integrates them into the current branch, usually through merge or rebase depending on the configuration and options used.

In simple terms:

```text
git fetch → download changes
git pull  → download + integrate changes
```

---

### 10. What is LVM and why would you use it instead of regular partitions?

LVM stands for Logical Volume Manager.

It provides a flexible way to manage storage by creating logical volumes from physical storage.

The main benefit is flexibility. Logical volumes can be resized and managed more easily compared with traditional fixed partitions.

---

## 4. Teach It Back – Git Reset vs Git Revert

Imagine I made a change to a project and committed it.

Later, I realize that the change was wrong and I want to undo it.

There are two common ways to do this: `git reset` and `git revert`.

`git reset` moves the branch pointer back to an earlier commit. Depending on the reset option, it can also change the staging area and working directory. With `--hard`, changes can be discarded.

`git revert` works differently. Instead of removing the old commit, Git creates a new commit that reverses the changes from the previous commit.

For a shared branch such as `main`, `git revert` is generally safer because the existing history remains intact.

The easiest way I remember it is:

```text
git reset  → move the branch backward
git revert → create a new commit to undo changes
```

---

## 5. Overall Takeaway

Day 28 was mainly about checking whether I could still use and explain the concepts I had learned during the previous 27 days.

Going through the quick-fire questions showed me that I understand the practical concepts, but sometimes my first explanation is not technically precise enough.

The revision helped me improve the way I explain concepts such as:

* Linux processes and services
* File permissions
* Shell error handling
* Git reset vs revert
* Git stash
* Git fetch vs pull
* LVM

The biggest takeaway from this revision is that **knowing a concept and being able to explain it clearly are two different skills**.

After 27 days of learning Linux, networking, shell scripting, Git, GitHub, and developer workflows, I now have a much stronger foundation to build on in the upcoming days.

**Day 28 complete.**
