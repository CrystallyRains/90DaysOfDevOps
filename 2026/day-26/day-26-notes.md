# Day 26 – GitHub CLI (`gh`): Manage GitHub from Your Terminal

> **Version used:** gh 2.98.0 (2026-08-20)  
> **Installed via:** `brew install gh`  
> **OS:** macOS (Apple Silicon)

---

## Table of Contents
1. [Install & Authenticate](#1-install--authenticate)
2. [Repositories](#2-repositories)
3. [Issues](#3-issues)
4. [Pull Requests](#4-pull-requests)
5. [GitHub Actions (Preview)](#5-github-actions--workflows-preview)
6. [Useful Tricks](#6-useful-gh-tricks)
7. [Gotchas & Lessons Learned](#7-gotchas--lessons-learned)

---

## 1. Install & Authenticate

### Install
```bash
# macOS
brew install gh

# Linux (Debian/Ubuntu)
sudo apt install gh

# Verify installation
gh --version          # gh version 2.98.0 (2026-08-20)
Authenticate
bash
gh auth login
# → Select: GitHub.com → HTTPS → Yes (authenticate Git) → Login with web browser
# → Copy one-time code (e.g., 0A3C-F5F6) → Press Enter → Browser opens → Paste code
Verify & Manage Auth
bash
gh auth status        # Shows active account, protocol, token scopes
gh auth token         # Prints the current auth token
gh auth logout        # Log out
gh auth refresh -h github.com -s delete_repo   # Add extra scopes (e.g., delete_repo)
Supported Authentication Methods
Table
Method	Use Case
Browser OAuth	Interactive login (default)
Personal Access Token (PAT)	Classic or fine-grained tokens
GH_TOKEN env var	Scripts / CI / non-interactive
SSH	For git operations only, not gh API calls
2. Repositories
Create a Repository
bash
# Public repo with README
gh repo create <name> --public --add-readme

# Private repo, no README, with description
gh repo create <name> --private --description "My project"

# From current directory (init and push)
gh repo create --source=. --public --push
Clone a Repository
bash
gh repo clone <owner>/<repo>
# Example: gh repo clone CrystallyRains/90DaysOfDevOps
# Uses HTTPS or SSH based on your gh auth protocol
View & List Repositories
bash
gh repo view <owner>/<repo>           # View README and details in terminal
gh repo view --web                    # Open repo in default browser
gh repo list <owner> --limit 30       # List repos (default limit is 30)
gh repo list <owner> --source         # Show only non-forks
Delete a Repository
bash
gh repo delete <owner>/<repo> --yes
# ⚠️ Requires 'delete_repo' scope. If missing:
# gh auth refresh -h github.com -s delete_repo
3. Issues
Create an Issue
bash
gh issue create --repo <owner>/<repo> \
  --title "Issue title" \
  --body "Detailed description" \
  --label "bug,documentation" \
  --assignee @me
List, View, Close Issues
bash
gh issue list --repo <owner>/<repo>              # List open issues
gh issue list --state all --limit 50             # List all (open + closed)
gh issue view <number> --repo <owner>/<repo>     # View specific issue
gh issue close <number> --repo <owner>/<repo>    # Close an issue
gh issue reopen <number>                         # Reopen a closed issue
JSON Output (for Scripting)
bash
gh issue list --json number,title,labels,updatedAt
Using gh issue in Automation
CI failure tracking: gh issue create in a GitHub Actions if: failure() step
Stale issue cleanup: Cron job that finds old issues and bulk-closes them
Dashboard feeds: Parse --json output to feed into Slack/Discord bots
Note: Issues are disabled by default on forks. Enable them in repo Settings → Issues, or use gh repo edit --enable-issues.
4. Pull Requests
Full PR Workflow (Terminal-Only)
bash
# 1. Create and switch to a new branch
git checkout -b <branch-name>

# 2. Make changes, commit, push
git add . && git commit -m "Your message"
git push -u origin <branch-name>

# 3. Create PR
gh pr create --fill                    # Auto-fill title/body from commits
gh pr create --title "..." --body "..." # Manual title/body

# 4. List and view PRs
gh pr list                             # Open PRs in default repo
gh pr list --repo <owner>/<repo>       # Target specific repo
gh pr view <number>                    # View PR details
gh pr view <number> --web              # Open PR in browser

# 5. Review PRs
gh pr checkout <number>                # Pull PR branch locally to test
gh pr diff <number>                    # View diff in terminal
gh pr review <number> --approve --body "LGTM"
gh pr comment <number> --body "Check line 42"

# 6. Merge PR
gh pr merge <number> --squash --delete-branch
gh pr merge <number> --merge --delete-branch
gh pr merge <number> --rebase --delete-branch
Merge Methods Supported
Table
Flag	Behavior
--merge	Standard merge commit (preserves all commits)
--squash	Squashes all commits into one (clean history)
--rebase	Rebase and fast-forward (linear history)
--delete-branch	Deletes the branch after merge (local + remote)
⚠️ CRITICAL: Fork Default Repo Gotcha
When you clone a fork, gh defaults PRs to the upstream repo, not your fork.
Fix it permanently:
bash
gh repo set-default CrystallyRains/90DaysOfDevOps
# Now all gh pr commands target YOUR fork
What happened to me:
First PR went to TrainWithShubham/90DaysOfDevOps (#761) — WRONG
Closed it: gh pr close 761 --repo TrainWithShubham/90DaysOfDevOps
Set default: gh repo set-default CrystallyRains/90DaysOfDevOps
Second PR went to my fork (#2) — CORRECT
Merged: gh pr merge 2 --squash --delete-branch
5. GitHub Actions & Workflows (Preview)
List and View Runs
bash
gh run list --repo <owner>/<repo>           # List recent workflow runs
gh run view <run-id> --repo <owner>/<repo>  # View specific run details
gh run view --job=<job-id>                  # View a specific job within a run
gh run watch <run-id>                       # Live-tail logs
Trigger and Manage Workflows
bash
gh workflow list --repo <owner>/<repo>      # List available workflows
gh workflow run <workflow.yml> --repo <owner>/<repo>
gh run rerun <run-id> --failed              # Rerun only failed jobs
gh run download <run-id>                    # Download artifacts
Use in CI/CD
Local debugging: Trigger workflows before pushing to avoid broken CI
Artifact retrieval: Download build outputs without opening browser
Failure response: Auto-rerun failed jobs from incident response scripts
6. Useful gh Tricks
Raw API Calls
bash
gh api <endpoint> --jq '<jq-filter>'
# Example:
gh api repos/CrystallyRains/90DaysOfDevOps --jq '.stargazers_count'
# Output: 0
GitHub Gists
bash
gh gist create <file> --public --desc "Description"
gh gist list                           # List your gists
gh gist view <id>                      # View a gist
Releases
bash
gh release create <tag> --notes "Release notes"
# Example:
gh release create v1.0.0 --notes "First stable release"
Aliases (Custom Shortcuts)
bash
# Create
gh alias set <name> "<command>"
gh alias set co "pr checkout"
gh alias set pv "pr view"

# Overwrite existing
gh alias set co --clobber "pr checkout"

# Use
gh co 5        # Same as: gh pr checkout 5
gh pv 2        # Same as: gh pr view 2

# List all aliases
gh alias list
Search
bash
gh search repos "<query>" --stars=">100" --language=HCL --sort=stars
# Example:
gh search repos "kubernetes terraform" --stars=">100" --language=HCL
7. Gotchas & Lessons Learned
Table
#	Gotcha	Solution
1	gh repo delete fails with 403	Run gh auth refresh -h github.com -s delete_repo
2	Issues disabled on fork	Enable in Settings, or use gh repo edit --enable-issues
3	PR defaults to upstream repo	Run gh repo set-default <your-fork>
4	gh auth whoami doesn't exist	Use gh auth status instead
5	gh gist create needs an actual file	Can't create from stdin without piping
My Favorite Commands from Today
gh pr create --fill — Zero-friction PR creation
gh pr merge <num> --squash --delete-branch — One-command merge + cleanup
gh repo set-default — Saved me from more accidental upstream PRs
gh alias set — Making my own shortcuts feels like custom tooling
Quick Reference Card
bash
# Auth
gh auth login / logout / status / refresh -s <scope>

# Repo
gh repo create / clone / view / list / delete

# Issue
gh issue create / list / view / close / reopen

# PR
gh pr create --fill / list / view / checkout / diff / review / merge --squash

# Actions
gh run list / view / watch / rerun / download
gh workflow list / run

# Utils
gh api / gist / release / alias / search
#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
