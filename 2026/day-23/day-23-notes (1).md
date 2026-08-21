# Day 23 – Git Branching & Working with GitHub

## Task

Learn how Git branches work, practice creating and switching branches, push branches to GitHub, pull changes from GitHub, and understand clone vs fork.

---

# Task 1: Understanding Branches

## 1. What is a branch in Git?

A branch is a separate line of development in a Git repository.

It allows me to work on a feature, fix, or experiment without directly changing the `main` branch.

For example:

```text
main
  |
  A---B
               C---D  feature-1
```

Here, `feature-1` starts from an existing commit on `main` and can have its own commits.

---

## 2. Why use branches instead of committing everything to `main`?

Branches keep different work separated.

For example, if I am working on a new feature:

```text
main       → stable code
feature-1  → new feature
feature-2  → another feature
```

This means I can work on a feature without risking the stable `main` branch.

Branches are useful for:

- New features
- Bug fixes
- Experiments
- Testing changes
- Working with other developers

Once the work is ready, the branch can be merged into `main`.

---

## 3. What is `HEAD` in Git?

`HEAD` points to the commit or branch I am currently working on.

For example:

```text
HEAD → feature-1
```

This means I am currently on the `feature-1` branch.

I can check where `HEAD` is by running:

```bash
git status
```

I can also see it in:

```bash
git log --oneline
```

where Git shows `HEAD -> branch-name`.

---

## 4. What happens to files when you switch branches?

When I switch branches, Git changes the files in my working directory to match the version stored in that branch.

For example:

```text
main
 └── README.md

feature-1
 ├── README.md
 └── feature.md
```

If I switch to `feature-1`, `feature.md` appears.

If I switch back to `main`, `feature.md` will not appear if it only exists on `feature-1`.

This is because each branch can point to a different set of commits and file states.

---

# Task 2: Branching Commands – Hands-On

## 1. List all branches

```bash
git branch
```

Example:

```text
* main
  feature-1
```

The `*` shows the branch I am currently on.

---

## 2. Create a new branch called `feature-1`

```bash
git branch feature-1
```

This creates the branch but does not switch to it.

---

## 3. Switch to `feature-1`

Using the modern `git switch` command:

```bash
git switch feature-1
```

Output:

```text
Switched to branch 'feature-1'
```

---

## 4. Create and switch to `feature-2` in one command

```bash
git switch -c feature-2
```

The `-c` means create a new branch and switch to it.

---

## 5. `git switch` vs `git checkout`

Both can be used to switch branches.

### `git switch`

```bash
git switch feature-1
```

`git switch` is designed specifically for branch switching and is easier to understand.

### `git checkout`

Older Git workflows commonly used:

```bash
git checkout feature-1
```

`git checkout` can do more than switching branches, including checking out files and commits.

For normal branch switching, I prefer:

```bash
git switch feature-1
```

---

## 6. Make a commit on `feature-1` that does not exist on `main`

First switch to the branch:

```bash
git switch feature-1
```

Make a change and commit it:

```bash
git add .
git commit -m "Add feature-1 changes"
```

Now the commit belongs to `feature-1`.

The commit is not automatically part of `main`.

I practiced this and had a separate commit on `feature-1`:

```text
ccb789c (feature-1) commiting for 1st one
939429c (main) now final commit
```

---

## 7. Switch back to `main` and verify

```bash
git switch main
```

Then:

```bash
git log --oneline
```

The commit made only on `feature-1` will not be part of `main` until the branches are merged.

I also verified the branch difference using:

```bash
git log main..feature-1 --oneline
```

This shows commits that exist on `feature-1` but not on `main`.

---

## 8. Delete a branch

When a branch is no longer needed:

```bash
git branch -d feature-2
```

I practiced this and Git confirmed:

```text
Deleted branch feature-2
```

---

## 9. Branching commands added to `git-commands.md`

Important commands:

```bash
git branch
git branch <branch-name>
git switch <branch-name>
git switch -c <branch-name>
git checkout <branch-name>
git branch -d <branch-name>
git log --oneline
git log main..feature-1 --oneline
```

---

# Task 3: Push to GitHub

## 1. Create a new repository on GitHub

The repository should be created without initializing it with a README because the local repository already exists.

---

## 2. Connect the local repository to GitHub

First check existing remotes:

```bash
git remote -v
```

If no remote exists:

```bash
git remote add origin https://github.com/USERNAME/REPOSITORY.git
```

`origin` is the conventional name for the main remote repository I work with.

---

## 3. Push the `main` branch

```bash
git push -u origin main
```

The `-u` sets the upstream tracking relationship so future pushes and pulls can use the configured remote branch.

I pushed my `main` branch successfully:

```text
* [new branch] main -> main
branch 'main' set up to track 'origin/main'
```

---

## 4. Push `feature-1`

```bash
git push -u origin feature-1
```

This creates the branch on GitHub.

I also received GitHub's message suggesting that a Pull Request could be created for `feature-1`.

---

## 5. Verify both branches

The branches can be checked locally with:

```bash
git branch
```

and verified on GitHub.

The repository contained:

```text
main
feature-1
```

---

## 6. What is the difference between `origin` and `upstream`?

### `origin`

`origin` normally refers to the remote repository that I cloned from or the remote repository where I push my work.

Example:

```text
origin → my GitHub repository
```

### `upstream`

`upstream` is commonly used when working with a fork.

It refers to the original repository from which my fork was created.

Example:

```text
upstream → original repository
origin   → my fork
```

These names are conventions. Git does not require a remote to be called `origin` or `upstream`.

---

# Task 4: Pull from GitHub

## 1. Make a change directly on GitHub

A file can be edited directly through GitHub's web editor and committed there.

This creates a new commit on the remote repository.

---

## 2. Pull the change to the local repository

```bash
git pull origin main
```

`git pull` gets changes from the remote repository and integrates them into the current local branch.

I practiced pulling changes from GitHub and saw Git download the new commit and fast-forward the local branch.

Example:

```text
From https://github.com/CrystallyRains/practice-devops-repo
1ce26ba..8db278f  main -> origin/main
```

---

## 3. Difference between `git fetch` and `git pull`

### `git fetch`

```bash
git fetch
```

Downloads changes from the remote repository but does not automatically merge them into my current branch.

For example:

```text
Remote
  ↓
git fetch
  ↓
origin/main updated
  ↓
local main unchanged
```

I practiced this and Git reported:

```text
Your branch is behind 'origin/main' by 1 commit
```

I then merged the fetched changes:

```bash
git merge
```

---

### `git pull`

```bash
git pull origin main
```

`git pull` gets the remote changes and integrates them into the current branch.

Simple way to remember:

```text
git fetch = download/check changes

git pull  = download + integrate changes
```

---

# Task 5: Clone vs Fork

## 1. Clone a public repository

I practiced cloning a public repository:

```bash
git clone https://github.com/CrystallyRains/Imagify-tf-ecs.git
```

Git downloaded the repository and created a local directory:

```text
Imagify-tf-ecs
```

Clone means copying a remote repository to my local computer.

---

## 2. Fork the same repository and clone the fork

A fork is created on GitHub.

The basic workflow is:

```text
Original GitHub Repository
          |
        Fork
          ↓
My GitHub Fork
          |
        Clone
          ↓
My Local Computer
```

Then my local repository can be connected to my fork.

---

## 3. What is the difference between clone and fork?

### Clone

A clone creates a local copy of a repository on my computer.

```bash
git clone <repository-url>
```

### Fork

A fork creates a GitHub copy of another person's repository under my own GitHub account.

A fork is a GitHub concept, while clone is a Git operation.

---

## 4. When would you clone vs fork?

### Clone

Use clone when I have permission to work directly with the repository.

Examples:

- My own repository
- Company repository where I have access
- Repository where I am a collaborator

```text
GitHub repository
       ↓ clone
Local computer
```

### Fork

Use fork when I want to work on another person's repository but do not have direct write access.

Typical open-source workflow:

```text
Original repo
     ↓
   Fork
     ↓
Your GitHub repo
     ↓
  Clone
     ↓
Your computer
     ↓
Changes + commit
     ↓
Push to your fork
     ↓
Pull Request to original repo
```

---

## 5. How do you keep a fork in sync with the original repo?

First, add the original repository as `upstream`:

```bash
git remote add upstream https://github.com/original-user/repository.git
```

Check the remotes:

```bash
git remote -v
```

The usual setup is:

```text
origin   → my fork
upstream → original repository
```

Fetch the latest changes:

```bash
git fetch upstream
```

Switch to the local `main` branch:

```bash
git switch main
```

Merge the original repository's main branch:

```bash
git merge upstream/main
```

Then push the updated main branch to my fork:

```bash
git push origin main
```

Complete flow:

```text
Original repository
       ↓
git fetch upstream
       ↓
Local main
       ↓
git merge upstream/main
       ↓
git push origin main
       ↓
My fork is updated
```

---

# Important Git Concepts from Day 23

## Branch

A separate line of development.

```bash
git branch feature-1
```

## HEAD

Points to the branch/commit I am currently working on.

## Origin

Usually the remote repository associated with my own working repository.

```text
origin → my GitHub repo
```

## Upstream

Usually the original repository when working with a fork.

```text
upstream → original GitHub repo
```

## Fetch

Downloads remote changes without automatically integrating them.

```bash
git fetch
```

## Pull

Downloads and integrates remote changes.

```bash
git pull
```

## Clone

Copies a remote repository to my local computer.

```bash
git clone <url>
```

## Fork

Creates a copy of a repository under my GitHub account.

---

# Day 23 Command Reference

```bash
# Branches
git branch
git branch <branch-name>
git switch <branch-name>
git switch -c <branch-name>
git branch -d <branch-name>

# Older branch switching command
git checkout <branch-name>

# View commits
git log --oneline
git log main..feature-1 --oneline

# Remotes
git remote -v
git remote add origin <url>
git remote add upstream <url>

# Push
git push -u origin main
git push -u origin <branch-name>

# Download remote changes
git fetch
git fetch upstream

# Pull and integrate changes
git pull origin main

# Merge
git merge
git merge upstream/main

# Clone
git clone <repository-url>
```

---

# Key Takeaways

```text
Branch
→ Separate line of development

HEAD
→ Where I am currently working

origin
→ Usually my main remote / fork

upstream
→ Usually the original repository

fetch
→ Download remote changes

pull
→ Download + integrate remote changes

clone
→ Copy GitHub repository to my computer

fork
→ Create my own GitHub copy of another repository
```

### Simple workflow to remember

```text
Create branch
     ↓
Work on feature
     ↓
Commit
     ↓
Push branch to GitHub
     ↓
Pull Request
     ↓
Merge into main
```

For an open-source project:

```text
Original repo
     ↓
Fork
     ↓
Clone fork
     ↓
Create branch
     ↓
Make changes
     ↓
Commit
     ↓
Push to fork
     ↓
Pull Request
```
