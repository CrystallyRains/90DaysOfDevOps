# Day 25 – Git Reset vs Revert & Branching Strategies

## Overview

Day 25 focused on safely undoing changes in Git and understanding branching strategies used by development teams.

Topics covered:

* `git reset`
* `git revert`
* `git reflog`
* Reset modes: `--soft`, `--mixed`, `--hard`
* Reset vs revert
* GitFlow
* GitHub Flow
* Trunk-Based Development
* Choosing a branching strategy

---

# Task 1 – Git Reset

## What is Git Reset?

`git reset` moves the current branch's `HEAD` to another commit.

Depending on the reset mode, it can also change what happens to the staging area and working directory.

### Basic Syntax

```bash
git reset [options] <commit>
```

Common forms:

```bash
git reset --soft <commit>
git reset --mixed <commit>
git reset --hard <commit>
```

---

## Reset Modes

Git reset affects three main areas:

```text
HEAD
  ↓
Staging Area
  ↓
Working Directory
```

The three reset modes behave differently depending on which of these areas they change.

---

## 1. `git reset --soft`

### Syntax

```bash
git reset --soft <commit>
```

### What it does

Moves `HEAD` to the specified commit but keeps the changes from the commits that were removed from the branch history **staged**.

Example:

```text
Before:

A---B---C
        ↑
       HEAD

git reset --soft B

After:

A---B
    ↑
   HEAD

Changes from C are still staged.
```

### When to use it

Use `--soft` when you want to undo one or more commits but keep all their changes ready to commit again.

Useful for:

* Fixing a commit message
* Combining commits
* Reworking recent commits
* Creating a cleaner commit

### Observation

After running:

```bash
git reset --soft 0745d27
```

the `HEAD` moved back to `Commit B`, while `readme.md` appeared under **Changes to be committed**.

This showed that the changes remained staged.

---

# 2. `git reset --mixed`

### Syntax

```bash
git reset --mixed <commit>
```

`--mixed` is also the default reset mode:

```bash
git reset <commit>
```

### What it does

Moves `HEAD` to the specified commit and unstages the changes.

The changes remain in the working directory.

Example:

```text
Before:

A---B---C
        ↑
       HEAD

git reset --mixed B

After:

A---B
    ↑
   HEAD

Changes from C remain as unstaged working-directory changes.
```

### When to use it

Use `--mixed` when you want to undo a commit but keep the changes so you can modify or selectively stage them again.

### Observation

After:

```bash
git reset --mixed 0745d27
```

Git reported:

```text
Unstaged changes after reset:
M readme.md
```

`readme.md` was no longer staged, but the changes were still present in the working directory.

---

# 3. `git reset --hard`

### Syntax

```bash
git reset --hard <commit>
```

### What it does

Moves `HEAD`, resets the staging area, and resets the working directory to match the specified commit.

Example:

```text
Before:

A---B---C
        ↑
       HEAD

git reset --hard B

After:

A---B
    ↑
   HEAD
```

Changes introduced by `C` are removed from the working directory.

### When to use it

Use `--hard` when you are completely sure that you do not need the changes you are removing.

It is useful for:

* Throwing away unwanted local changes
* Returning a local branch to an earlier state
* Cleaning up a practice repository

### Important

`--hard` is the most destructive reset mode because it can remove uncommitted working-directory changes.

However, Git's `reflog` can often help recover commits that were moved away from by a reset.

### Observation

After:

```bash
git reset --hard 0745d27
```

Git reported:

```text
HEAD is now at 0745d27 Commit B done
```

The working tree became clean and `Commit C` was no longer part of the current branch history.

---

# Soft vs Mixed vs Hard

| Mode      | HEAD  | Staging Area            | Working Directory |
| --------- | ----- | ----------------------- | ----------------- |
| `--soft`  | Reset | Changes remain staged   | Changes remain    |
| `--mixed` | Reset | Changes become unstaged | Changes remain    |
| `--hard`  | Reset | Reset                   | Reset             |

### Easy way to remember

```text
--soft
Move HEAD only

--mixed
Move HEAD + unstage changes

--hard
Move HEAD + unstage + discard working changes
```

---

# Which Reset Mode Is Destructive?

`git reset --hard` is the most destructive because it can discard changes from the working directory and staging area.

It should be used carefully, especially when working with important code.

---

# Should You Use `git reset` on Already-Pushed Commits?

Generally, **avoid resetting commits that have already been pushed and shared with other developers**.

Reset changes the branch history.

If the remote branch has already been shared, resetting locally and force-pushing can cause problems for other developers who already based their work on the original history.

For shared branches, `git revert` is usually the safer choice.

---

# Task 2 – Git Revert

## What is Git Revert?

`git revert` creates a **new commit that reverses the changes introduced by an earlier commit**.

Unlike reset, revert does not remove the original commit from history.

### Syntax

```bash
git revert <commit-hash>
```

### Example

```bash
git revert 41a2b35
```

This creates a new commit that reverses the changes introduced by `41a2b35`.

---

## Example

Before revert:

```text
A---B---C
        ↑
       HEAD
```

If `B` is reverted:

```text
A---B---C---R
            ↑
           HEAD
```

`R` is a new revert commit.

The original `B` remains in the history.

---

## What Happened During Practice?

The repository had:

```text
Commit X
Commit Y
Commit Z
```

The commit hash for `Commit Y` was:

```text
41a2b35
```

Running:

```bash
git revert 41a2b35
```

created:

```text
14bf973 Revert "Commit Y"
```

The log showed both commits:

```text
14bf973 Revert "Commit Y"
0e60fac Commit X
41a2b35 Commit Y
641f75e Commit Z
```

This demonstrates that **revert does not delete the original commit**.

Instead, it adds another commit that reverses its changes.

---

## Revert Conflicts

A revert can also produce a conflict.

This happened while reverting an earlier commit because later changes had modified the same file.

Git reported:

```text
CONFLICT (content): Merge conflict in readme.md
```

During a revert conflict, the usual process is:

```bash
# Resolve the conflicting file

git add <file>

git revert --continue
```

Other useful commands are:

```bash
git revert --abort
```

Cancels the revert and returns to the state before the revert started.

```bash
git revert --skip
```

Skips the current revert operation when appropriate.

---

# How Is Revert Different from Reset?

### Reset

Moves the branch pointer to an earlier commit.

```text
A---B---C
        ↑

reset to B

A---B
    ↑
```

The branch no longer points to `C`.

### Revert

Creates a new commit that reverses an earlier commit.

```text
A---B---C---R
            ↑
```

The original commit remains visible.

---

# Why Is Revert Safer for Shared Branches?

Revert does not rewrite existing history.

Instead, it adds another commit.

Therefore, other developers who already pulled the original commits can continue working with the same history.

This makes revert much safer for shared branches such as `main`.

---

# When to Use Reset vs Revert?

## Use Reset When:

* Working on your own local branch
* Commits have not been shared
* You want to clean up local history
* You want to undo recent local commits
* You want to keep or discard the changes depending on the reset mode

## Use Revert When:

* The commit has already been pushed
* Other developers may have pulled the commit
* You need to safely undo a change on a shared branch
* You want to preserve the existing history

---

# Task 3 – Reset vs Revert Summary

|                                  | `git reset`                                                   | `git revert`                                      |
| -------------------------------- | ------------------------------------------------------------- | ------------------------------------------------- |
| What it does                     | Moves `HEAD` to another commit                                | Creates a new commit that reverses another commit |
| Removes commit from history?     | It can make commits disappear from the current branch history | No                                                |
| Rewrites history?                | Yes                                                           | No                                                |
| Safe for shared/pushed branches? | Generally no                                                  | Yes                                               |
| Best used for                    | Local/private history cleanup                                 | Undoing changes on shared branches                |
| Creates a new commit?            | No                                                            | Yes                                               |

### Simple rule

> **Reset rewrites history. Revert adds to history.**

---

# Task 4 – Branching Strategies

Different teams use different branching strategies depending on how they develop, test, review, and release software.

The three strategies studied here are:

1. GitFlow
2. GitHub Flow
3. Trunk-Based Development

---

# 1. GitFlow

## How It Works

GitFlow uses multiple long-lived branches with specific purposes.

The main branches are:

* `main`
* `develop`

Additional branches include:

* `feature/*`
* `release/*`
* `hotfix/*`

Typical flow:

```text
                    feature
                       |
                       v
main ------------ develop
                       |
                       v
                    release
                       |
                       v
                     main
                       ^
                       |
                    hotfix
```

A more detailed flow:

```text
feature/login
      |
      v
   develop
      |
      v
release/1.0
      |
      +------> main
      |
      +------> develop

hotfix
   |
   +------> main
   |
   +------> develop
```

### Feature Branch

Feature branches are created from `develop`.

```bash
git checkout develop
git checkout -b feature/login
```

When complete, the feature is merged back into `develop`.

### Release Branch

A release branch is created from `develop` when preparing a release.

```text
develop
   |
   v
release/1.0
   |
   +----> main
   |
   +----> develop
```

### Hotfix Branch

A hotfix branch is used for urgent fixes to production.

It is typically created from `main` and merged back into `main` and `develop`.

---

## When Is GitFlow Used?

GitFlow was designed around projects with scheduled releases and explicit release preparation phases.

It can make release management structured, but it introduces more branches and more process.

Modern teams doing continuous delivery often prefer simpler approaches.

---

## Pros

* Clear separation between development and releases
* Dedicated release branches
* Dedicated hotfix workflow
* Useful when releases are scheduled
* Provides a defined process for larger release cycles

## Cons

* More branches to manage
* More complex workflow
* Longer-lived branches can diverge
* More merge conflicts are possible
* Can be cumbersome for continuous delivery

---

# 2. GitHub Flow

## How It Works

GitHub Flow is a simpler branching model centered around one main branch.

Typical workflow:

```text
             feature branch
                  |
                  v
main ---------- feature
  |                |
  |             commits
  |                |
  |                v
  |           Pull Request
  |                |
  +<---------------+
          merge
```

Typical process:

```text
main
  |
  +----> feature branch
              |
           changes
              |
              v
        Pull Request
              |
           review
              |
              v
            main
```

Developers create a branch from `main`, make their changes, push the branch, open a pull request, review the changes, and merge the branch back into `main`.

GitHub's documentation describes this workflow around creating a branch, committing changes, opening a pull request, reviewing the changes, and merging into `main`.

---

## When Is GitHub Flow Used?

GitHub Flow works well for:

* Web applications
* Continuous deployment
* Teams releasing frequently
* Projects using pull requests
* Teams that want a simple workflow

---

## Pros

* Simple to understand
* Fewer branches
* Easy pull-request workflow
* Works well with CI/CD
* Faster development cycle
* Less branch-management overhead

## Cons

* Less structured for complex scheduled release processes
* Requires strong CI/CD and testing
* Release management may need additional practices
* Teams may need tags or release branches for certain release requirements

---

# 3. Trunk-Based Development

## How It Works

Trunk-Based Development focuses on keeping developers close to a single shared branch called the **trunk**, commonly `main`.

Developers either commit directly to the trunk or use very short-lived feature branches.

```text
             short-lived branch
                    |
                    v
main ----A----B----C----D----E----F----G
              \         /
               ---------
```

The important idea is that changes are integrated into the main line frequently rather than remaining isolated for a long time.

Trunk-Based Development emphasizes frequent integration and keeping branches short-lived.

---

## Typical Workflow

```text
main
 |
 +----> short-lived branch
 |             |
 |          changes
 |             |
 +<------------+
 |
 +----> next change
```

Teams practicing trunk-based development may also use feature flags to merge incomplete functionality safely without exposing it to users.

For teams that release less frequently, a short-lived release branch can also be created when needed rather than maintaining long-lived release branches.

---

## When Is Trunk-Based Development Used?

It works particularly well for:

* Continuous integration
* Continuous delivery
* Frequent releases
* Teams with strong automated testing
* Teams wanting to minimize long-lived branch divergence

---

## Pros

* Very frequent integration
* Fewer long-lived branches
* Reduced merge complexity
* Works well with CI/CD
* Encourages small changes
* Keeps the main line close to releasable

## Cons

* Requires strong automated testing
* Requires good CI/CD practices
* Developers need discipline
* Incomplete features may require feature flags
* Direct commits to the trunk can be risky without safeguards

---

# Branching Strategy Comparison

| Strategy    | Main Idea                                      | Branch Complexity | Best For                                 |
| ----------- | ---------------------------------------------- | ----------------: | ---------------------------------------- |
| GitFlow     | Multiple branches for development and releases |              High | Scheduled releases                       |
| GitHub Flow | `main` + short-lived feature branches          |               Low | Continuous delivery and simple workflows |
| Trunk-Based | Frequent integration into one main trunk       |          Very Low | CI/CD and fast integration               |

---

# Which Strategy Would I Use for a Startup Shipping Fast?

For a startup shipping quickly, I would prefer **GitHub Flow or Trunk-Based Development**.

A simple workflow such as:

```text
main
  |
  +----> feature
             |
          Pull Request
             |
             v
            main
```

keeps the process lightweight and reduces unnecessary branch management.

If the team has strong automated testing and CI/CD, Trunk-Based Development would also be a strong choice.

---

# Which Strategy Would I Use for a Large Team with Scheduled Releases?

For a large team with formal, scheduled release cycles, **GitFlow can provide more structure** around feature development, release preparation, and hotfixes.

However, the choice depends on the team's release process. GitFlow is more complex and is now generally less favored for modern continuous-delivery environments.

---

# Open-Source Project Example

## Kubernetes

Kubernetes is a useful example of a large open-source project to examine when thinking about branching and release management.

Its development process uses the main development line along with release-specific branches and other branch/release conventions rather than following the classic GitFlow model exactly.

The important takeaway is that large projects often adapt branching practices to their release process instead of following one branching strategy rigidly.

---

# Task 5 – Git Commands Reference Update

The Git command reference should cover everything learned from Days 22–25.

## Setup & Configuration

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --list
```

### Purpose

Configure Git identity and view Git configuration.

---

## Basic Workflow

### Check repository status

```bash
git status
```

### Stage a file

```bash
git add <file>
```

### Stage everything

```bash
git add .
```

### Commit changes

```bash
git commit -m "Commit message"
```

### View commit history

```bash
git log
git log --oneline
git log --oneline --graph --all
```

### View changes

```bash
git diff
git diff --staged
```

---

# Branching

### List branches

```bash
git branch
```

### Create a branch

```bash
git branch <branch-name>
```

### Create and switch to a branch

```bash
git checkout -b <branch-name>
```

### Switch branches

```bash
git checkout <branch-name>
```

or:

```bash
git switch <branch-name>
```

### Delete a merged branch

```bash
git branch -d <branch-name>
```

### Force-delete a branch

```bash
git branch -D <branch-name>
```

Use `-D` carefully because it bypasses Git's protection against deleting an unmerged branch.

---

# Remote Operations

### Clone a repository

```bash
git clone <repository-url>
```

### View remotes

```bash
git remote -v
```

### Fetch changes

```bash
git fetch
```

### Pull changes

```bash
git pull
```

### Push a branch

```bash
git push origin <branch-name>
```

### Push and set upstream

```bash
git push -u origin <branch-name>
```

---

# Merge & Rebase

### Merge

```bash
git merge <branch-name>
```

### Rebase

```bash
git rebase <branch-name>
```

### Continue rebase

```bash
git rebase --continue
```

### Abort rebase

```bash
git rebase --abort
```

---

# Squash Merge

```bash
git merge --squash <branch-name>
git commit -m "Add feature"
```

---

# Stash

### Save changes

```bash
git stash
```

### Save with a message

```bash
git stash push -m "Description"
```

### List stashes

```bash
git stash list
```

### Apply latest stash

```bash
git stash apply
```

### Apply a specific stash

```bash
git stash apply stash@{1}
```

### Pop latest stash

```bash
git stash pop
```

### Delete a stash

```bash
git stash drop stash@{0}
```

### Delete all stashes

```bash
git stash clear
```

---

# Cherry-Pick

### Apply a specific commit

```bash
git cherry-pick <commit-hash>
```

### Continue after resolving a conflict

```bash
git cherry-pick --continue
```

### Abort cherry-pick

```bash
git cherry-pick --abort
```

### Skip a commit

```bash
git cherry-pick --skip
```

---

# Reset

### Soft reset

```bash
git reset --soft <commit>
```

Keeps changes staged.

### Mixed reset

```bash
git reset --mixed <commit>
```

Keeps changes but unstages them.

### Hard reset

```bash
git reset --hard <commit>
```

Resets the working tree as well.

### Default reset

```bash
git reset <commit>
```

Equivalent to:

```bash
git reset --mixed <commit>
```

---

# Revert

### Revert a commit

```bash
git revert <commit-hash>
```

Creates a new commit that reverses the selected commit.

### Continue after conflict resolution

```bash
git revert --continue
```

### Abort revert

```bash
git revert --abort
```

### Skip a revert

```bash
git revert --skip
```

---

# Reflog

### View reference history

```bash
git reflog
```

`git reflog` records movements of `HEAD`, including operations such as:

* Commits
* Resets
* Rebases
* Checkouts
* Merges
* Cherry-picks
* Reverts

It is particularly useful for recovering from mistakes such as an accidental reset.

Example:

```bash
git reflog
```

can show an earlier commit that is no longer visible in the normal branch history.

---

# Key Takeaways

## Reset

> Moves the branch pointer and can rewrite local history.

## Revert

> Creates a new commit that undoes an earlier commit.

## Reflog

> Shows where `HEAD` has been and can help recover lost commits.

## GitFlow

> Structured branching model with `develop`, feature, release, and hotfix branches.

## GitHub Flow

> Simple `main` + feature branch + pull request workflow.

## Trunk-Based Development

> Frequent integration into a shared trunk using either direct commits or short-lived branches.

---

# Final Cheat Sheet

```text
Need to undo local commits?
        ↓
     RESET

Need to undo a shared/pushed commit?
        ↓
     REVERT

Lost a commit after reset?
        ↓
     REFLOG

Need to combine branches?
        ↓
     MERGE

Need cleaner local history?
        ↓
     REBASE

Need to temporarily save unfinished work?
        ↓
     STASH

Need only one specific commit from another branch?
        ↓
   CHERRY-PICK

Need one clean commit from many feature commits?
        ↓
   SQUASH MERGE
```

# Final Takeaways

Day 25 helped me understand that Git does not only provide commands for creating and merging changes — it also provides different ways to safely undo mistakes.

The most important distinction is:

```text
RESET  → changes history
REVERT → adds a new commit to undo history
```

For local work, reset can be useful for cleaning up commits.

For shared branches, revert is generally safer because it preserves the existing history.

`git reflog` provides an additional safety net when recovering from operations such as reset.

Branching strategies also depend on how a team develops and releases software. GitFlow provides more structure, while GitHub Flow and Trunk-Based Development favor simpler and faster integration workflows.
