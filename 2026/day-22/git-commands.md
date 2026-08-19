# Day 22 – Git Basics

## What I Learned

Git is a version control system used to track changes in files and maintain a history of those changes.

Today I created a Git repository from scratch, created a Git command reference, staged and committed changes, and explored Git history.

---

## 1. What is the difference between `git add` and `git commit`?

`git add` moves changes from the working directory to the staging area.

`git commit` saves the staged changes into the Git repository as a commit.

In simple terms:

```text
git add → prepare the changes
git commit → save the changes
```

---

## 2. What does the staging area do? Why doesn't Git just commit directly?

The staging area lets me choose exactly which changes should be included in the next commit.

For example, if I modify three files but only want to commit one of them, I can stage only that file.

This makes commits more organized and meaningful.

---

## 3. What information does `git log` show?

`git log` shows the commit history of the repository.

It can show:

* Commit ID
* Author
* Date
* Commit message

`git log --oneline` shows the same history in a shorter format.

Example:

```text
06f4de8 Remove accidental file
010c4f2 Add Git commands for viewing changes
630a5b6 Add Git command reference
```

---

## 4. What is the `.git/` folder and what happens if you delete it?

The `.git/` folder contains the information Git uses to manage the repository, including its history, configuration, objects, and references.

If `.git/` is deleted, the files in the directory remain, but Git no longer considers the directory a Git repository.

The Git history stored in that `.git/` directory is also lost.

---

## 5. What is the difference between a working directory, staging area, and repository?

### Working Directory

The files I am currently creating or modifying.

### Staging Area

The changes I have selected to include in my next commit.

### Repository

The committed history stored by Git.

The basic workflow is:

```text
Working Directory
       ↓
    git add
       ↓
Staging Area
       ↓
  git commit
       ↓
Repository
```

---

## Commands Practiced Today

```bash
git --version
git config
git config --list
git init
git status
git add
git add -u
git diff
git diff --staged
git commit
git log
git log --oneline
```

## Day 22 Commit History

```text
06f4de8 Remove accidental file
010c4f2 Add Git commands for viewing changes
630a5b6 Add Git command reference
```
