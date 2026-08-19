# Git Commands

## Setup & Configuration

### `git --version`

Checks the installed Git version.

```bash
git --version
```

### `git config`

Sets Git username and email.

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### `git config --list`

Shows Git configuration.

```bash
git config --global --list
```

---

## Repository Setup

### `git init`

Initializes a directory as a Git repository.

```bash
git init
```

### `git status`

Shows the current state of the working directory and staging area.

```bash
git status
```

---

## Basic Workflow

### `git add`

Stages changes for the next commit.

```bash
git add filename
git add .
```

### `git commit`

Saves staged changes to the repository with a message.

```bash
git commit -m "Add Git command reference"
```

---

## Viewing Changes

### `git diff`

Shows changes that have not been staged.

```bash
git diff
```

### `git diff --staged`

Shows changes that are currently staged.

```bash
git diff --staged
```

---

## Viewing History

### `git log`

Shows the commit history.

```bash
git log
```

### `git log --oneline`

Shows the commit history in a compact format.

```bash
git log --oneline
```
