# Day 24 – Advanced Git: Merge, Rebase, Stash & Cherry-Pick

## Overview

Day 24 focused on advanced Git operations used when working with multiple branches and managing changes during development.

Topics covered:

* Git Merge
* Fast-forward and merge commits
* Merge conflicts
* Git Rebase
* Squash merging
* Git Stash
* Git Cherry-Pick

---

# Task 1 – Git Merge

## What is Git Merge?

`git merge` combines the changes from one branch into another branch.

The branch currently checked out is the branch that receives the changes.

### Syntax

```bash
git merge <branch-name>
```

### Example

```bash
git checkout main
git merge feature-login
```

This merges `feature-login` into `main`.

---

## Commands Used

### Create and switch to a new branch

```bash
git checkout -b feature-login
```

**Syntax:**

```bash
git checkout -b <branch-name>
```

Creates a new branch and switches to it.

---

### Switch branches

```bash
git checkout main
```

**Syntax:**

```bash
git checkout <branch-name>
```

Switches to an existing branch.

Modern alternative:

```bash
git switch <branch-name>
```

---

### Merge a branch

```bash
git merge feature-login
```

Merges `feature-login` into the currently checked-out branch.

---

### View branch history

```bash
git log --oneline --graph --all
```

Shows the commit history of all branches in a compact graphical format.

This is useful for understanding branches, merges, and how the history is connected.

---

## Fast-Forward Merge

A **fast-forward merge** happens when the target branch has not moved forward since the feature branch was created.

Example:

```text
A---B---C
    ^
   main
        ^
   feature-login
```

If `main` is still at `B` and `feature-login` contains `C`, Git can simply move `main` forward:

```text
A---B---C
        ^
   main, feature-login
```

No new merge commit is created.

### Key point

A fast-forward merge simply moves the branch pointer forward.

---

## Merge Commit

A merge commit is created when both branches have new commits and the histories have diverged.

Example:

```text
        C---D  feature-login
       /
A---B
       \
        E---F  main
```

After merging, Git may create:

```text
        C---D
       /     \
A---B         M
       \     /
        E---F
```

`M` is the merge commit.

### Key point

A merge commit connects two separate lines of development.

---

## Merge Conflict

A **merge conflict** happens when Git cannot automatically combine changes from two branches.

This commonly happens when:

* Two branches modify the same line.
* One branch deletes a file while another modifies it.
* Conflicting changes are made to the same part of a file.

Git marks the conflict in the file:

```text
<<<<<<< HEAD
Change from main
=======
Change from feature
>>>>>>> feature-login
```

The developer must manually decide which changes to keep.

After resolving the conflict:

```bash
git add <file>
git commit
```

completes the merge.

---

## Answers

### What is a fast-forward merge?

A fast-forward merge happens when the target branch has no new commits after the feature branch was created. Git can simply move the target branch pointer forward without creating a merge commit.

### When does Git create a merge commit?

Git creates a merge commit when the branches have diverged and both contain commits that are not present in the other branch.

### What is a merge conflict?

A merge conflict occurs when Git cannot automatically combine changes from two branches. The conflicting files must be manually edited and resolved.

---

# Task 2 – Git Rebase

## What is Git Rebase?

`git rebase` moves or replays the commits from one branch on top of another branch.

It is commonly used to create a cleaner, more linear project history.

### Syntax

```bash
git rebase <base-branch>
```

### Example

```bash
git checkout feature-dashboard
git rebase main
```

This takes the commits from `feature-dashboard` and replays them on top of the latest `main`.

---

## Example

Before rebase:

```text
        C---D  feature-dashboard
       /
A---B---E---F  main
```

After:

```text
A---B---E---F---C'---D'
                     ^
              feature-dashboard
```

The original commits `C` and `D` are recreated as new commits `C'` and `D'`.

---

## Commands Used

### Rebase onto another branch

```bash
git rebase main
```

Replays the current branch's commits on top of `main`.

---

### Continue a rebase after resolving a conflict

```bash
git add <file>
git rebase --continue
```

Used after manually resolving a conflict during a rebase.

---

### Abort a rebase

```bash
git rebase --abort
```

Cancels the current rebase and returns the branch to its previous state.

---

### View the history

```bash
git log --oneline --graph --all
```

Useful for comparing the history before and after a rebase.

---

## What does Rebase Actually Do?

Rebase takes the commits from the current branch and **replays them on top of another branch**.

The commits are recreated, which means they receive new commit IDs.

Rebase therefore changes the commit history.

---

## Rebase vs Merge

### Merge

Merge preserves the existing branch history.

```text
        C---D
       /     \
A---B         M
       \     /
        E---F
```

### Rebase

Rebase creates a more linear history.

```text
A---B---E---F---C'---D'
```

### Main difference

**Merge:** preserves the history of how branches came together.

**Rebase:** rewrites the branch history to make it appear more linear.

---

## Why Should You Not Rebase Shared Commits?

Rebase changes commit history and creates new commit IDs.

If commits have already been pushed and other developers are working with them, rebasing can cause:

* Different commit histories between developers
* Duplicate-looking commits
* Difficult synchronization
* Need for force pushing
* Possible loss of other people's work if handled incorrectly

Therefore, avoid rebasing commits that have already been shared with others.

---

## When Should You Use Rebase vs Merge?

### Use Merge When:

* Working on shared branches
* You want to preserve the actual branch history
* You want a safer approach that does not rewrite existing commits

### Use Rebase When:

* Working on your own local feature branch
* You want to update your branch with the latest `main`
* You want a clean and linear history
* The commits have not been shared with others

---

# Task 3 – Squash Commit vs Merge Commit

## What is Squash Merge?

A squash merge combines all commits from a feature branch into **one new commit** on the target branch.

### Syntax

```bash
git checkout main
git merge --squash feature-profile
git commit -m "Add profile feature"
```

`git merge --squash` prepares the combined changes but does not automatically create the commit.

The changes must then be committed separately.

---

## Example

Suppose a feature branch has:

```text
A---B---C---D---E  feature-profile
```

Where `B`, `C`, `D`, and `E` are small development commits.

With squash merge, `main` receives one new commit:

```text
A---S  main
```

`S` contains all the changes from the feature branch.

---

## Regular Merge

A normal merge preserves the individual commits.

```bash
git checkout main
git merge feature-settings
```

The individual commits remain visible in the history.

---

## Commands Used

### Squash merge

```bash
git merge --squash <branch-name>
```

Combines the changes from the branch without bringing its individual commits into the target branch history.

A separate `git commit` is required.

---

### Regular merge

```bash
git merge <branch-name>
```

Combines the branch and preserves its commit history.

---

## What Does Squash Merging Do?

Squash merging combines multiple feature-branch commits into a single commit on the target branch.

For example:

```text
Feature branch:
Commit 1
Commit 2
Commit 3
Commit 4
```

becomes:

```text
Main:
One feature commit
```

---

## When Would You Use Squash Merge?

Squash merge is useful when a feature branch contains many small or messy commits such as:

* Typo fixes
* Formatting changes
* Debugging commits
* Temporary changes
* Multiple small development steps

It keeps the main branch history cleaner.

---

## When Would You Use Regular Merge?

Regular merge is useful when the individual commits provide meaningful history and you want to preserve the development process.

For example, commits might represent:

* Separate logical changes
* Important fixes
* Different parts of a feature
* Changes that may be useful for troubleshooting later

---

## Trade-off of Squashing

### Advantages

* Cleaner main branch history
* Fewer commits
* Easier to read project history
* Hides unnecessary development commits

### Disadvantages

* Individual commits from the feature branch are no longer visible on the target branch
* Some detailed development history is lost
* It can make it harder to understand how the feature was developed

---

# Task 4 – Git Stash

## What is Git Stash?

`git stash` temporarily saves uncommitted changes so the working directory can be cleaned.

It is useful when you are working on something but suddenly need to switch branches or work on another task.

Instead of committing incomplete work, you can stash it.

---

## Commands Used

### Save changes

```bash
git stash
```

Temporarily saves tracked, uncommitted changes.

---

### Stash with a message

```bash
git stash push -m "description"
```

**Example:**

```bash
git stash push -m "Work in progress on login"
```

This makes it easier to identify the stash later.

---

### View all stashes

```bash
git stash list
```

Example:

```text
stash@{0}: On main: Work in progress
stash@{1}: On feature-login: Login changes
```

---

### Apply the latest stash

```bash
git stash apply
```

Restores the latest stash but keeps it in the stash list.

---

### Apply a specific stash

```bash
git stash apply stash@{1}
```

Restores a specific stash without removing it from the stash list.

---

### Pop the latest stash

```bash
git stash pop
```

Restores the latest stash and removes it from the stash list if it applies successfully.

---

### Remove a stash

```bash
git stash drop stash@{0}
```

Deletes a specific stash.

---

### Remove all stashes

```bash
git stash clear
```

Deletes all stored stashes.

---

## `git stash pop` vs `git stash apply`

| Command           | Restores changes | Removes stash |
| ----------------- | ---------------- | ------------- |
| `git stash apply` | Yes              | No            |
| `git stash pop`   | Yes              | Yes           |

### Simple way to remember

**Apply = restore and keep**

**Pop = restore and remove**

---

## When Would You Use Stash?

A common real-world situation:

1. You are working on a feature.
2. Your changes are incomplete.
3. A production bug needs immediate attention.
4. You need to switch to another branch.
5. You stash your current work.
6. You fix the urgent issue.
7. You return to your feature branch.
8. You restore the stashed changes.

Example:

```bash
git stash push -m "Dashboard work in progress"
git checkout main

# Work on urgent issue

git checkout feature-dashboard
git stash pop
```

Stash is useful for **temporary work-in-progress changes that are not ready to commit**.

---

# Task 5 – Git Cherry-Pick

## What is Git Cherry-Pick?

`git cherry-pick` applies the changes introduced by a specific commit to the current branch.

Instead of merging an entire branch, you can select only one commit.

### Syntax

```bash
git cherry-pick <commit-hash>
```

### Example

```bash
git cherry-pick 70f787b
```

This applies the changes from commit `70f787b` to the current branch.

---

## Finding a Commit Hash

Use:

```bash
git log --oneline
```

Example:

```text
2a9e3f8 Hotfix Step 3
70f787b Hotfix Step 2
666e88d Hotfix Step 1
```

The commit hash can then be used with:

```bash
git cherry-pick 70f787b
```

---

## What Does Cherry-Pick Do?

Cherry-pick takes the changes introduced by a specific commit and applies those changes to the current branch.

It creates a **new commit** on the current branch.

For example:

```text
feature-hotfix:

666e88d  Step 1
70f787b  Step 2
2a9e3f8  Step 3
```

If only Step 2 is needed on `main`:

```bash
git checkout main
git cherry-pick 70f787b
```

Only the changes from Step 2 are applied to `main`.

---

## When Would You Use Cherry-Pick?

Cherry-pick is useful when you need a specific change without merging an entire branch.

Common situations include:

* Applying a specific bug fix to another branch
* Moving a hotfix to a release branch
* Backporting a fix
* Selecting one useful commit from a feature branch
* Applying an isolated change without merging unrelated work

---

## What Can Go Wrong with Cherry-Pick?

Cherry-picking can cause conflicts if the changes from the selected commit do not fit cleanly into the current branch.

A conflict may need to be resolved manually.

After resolving:

```bash
git add <file>
git cherry-pick --continue
```

To cancel the cherry-pick:

```bash
git cherry-pick --abort
```

To skip the current commit:

```bash
git cherry-pick --skip
```

---

# Quick Comparison

| Git Operation    | Main Purpose                                     |
| ---------------- | ------------------------------------------------ |
| `merge`          | Combine branches                                 |
| `rebase`         | Replay commits on top of another branch          |
| `merge --squash` | Combine multiple feature commits into one commit |
| `stash`          | Temporarily save uncommitted work                |
| `cherry-pick`    | Apply one specific commit to another branch      |

---

## Merge vs Rebase

| Merge                        | Rebase                          |
| ---------------------------- | ------------------------------- |
| Preserves branch history     | Rewrites branch history         |
| Can create a merge commit    | Creates new versions of commits |
| Safer for shared branches    | Best for private/local branches |
| History can contain branches | Produces a more linear history  |

---

## Stash: Apply vs Pop

```text
git stash apply
        ↓
Restore changes
        ↓
Stash remains
```

```text
git stash pop
        ↓
Restore changes
        ↓
Stash is removed
```

---

## Cherry-Pick vs Merge

### Merge

```bash
git merge feature-branch
```

Brings the branch's changes and history together.

### Cherry-Pick

```bash
git cherry-pick <commit>
```

Selects a specific commit instead of merging the entire branch.

---

# Key Takeaways

* **Merge** combines branches.
* **Fast-forward merge** moves a branch pointer forward without creating a merge commit.
* **Merge commits** are created when branches have diverged.
* **Merge conflicts** happen when Git cannot automatically combine changes.
* **Rebase** replays commits on top of another branch and creates a cleaner linear history.
* Avoid rebasing commits that have already been shared with others.
* **Squash merge** combines multiple feature commits into one commit.
* **Stash** temporarily stores uncommitted work.
* `git stash apply` restores a stash and keeps it.
* `git stash pop` restores a stash and removes it.
* **Cherry-pick** applies a specific commit to the current branch.
* Cherry-picking is useful for selectively applying hotfixes or individual changes.
* `git log --oneline --graph --all` is one of the most useful commands for understanding Git history.
