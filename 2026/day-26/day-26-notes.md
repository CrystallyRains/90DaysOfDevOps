# Day 26 — GitHub CLI (`gh`)

> **gh version:** 2.98.0  
> **Installed via:** `brew install gh` on macOS  
> **Date:** 24 Aug 2026

---

## What is `gh`?

It's GitHub's official CLI tool. Instead of jumping between your terminal and browser to create PRs, check issues, or manage repos — you do everything from the command line. Super handy for DevOps because you can script a lot of this stuff later.

---

## 1. Install & Login

```bash
# Install
brew install gh

# Check version
gh --version

# Login — it opens a browser tab, you paste a code, done
gh auth login
```

When you run `gh auth login`, it asks you a few questions:
- GitHub.com or Enterprise? → GitHub.com
- HTTPS or SSH? → HTTPS (easiest)
- Authenticate Git too? → Yes
- How? → Login with web browser

It gives you a one-time code (like `0A3C-F5F6`). Copy it, press Enter, browser opens, paste it in. Done.

### Check if you're logged in

```bash
gh auth status
```

This shows your username, what protocol you're using, and what scopes your token has (like `repo`, `gist`, `workflow`, etc.).

**Note:** `gh auth whoami` doesn't exist — I tried it and got an error. Use `gh auth status` instead.

### What auth methods does `gh` support?

- **Browser OAuth** — the interactive login flow (what I used)
- **Personal Access Token (PAT)** — classic or fine-grained tokens
- **`GH_TOKEN` environment variable** — for scripts and automation where you can't interact

---

## 2. Working with Repos

### Create a repo from terminal

```bash
gh repo create test-gh-cli --public --add-readme
```

Flags:
- `--public` / `--private` — visibility
- `--add-readme` — initializes with a README
- `--clone` — clones it immediately after creating

### Clone a repo

```bash
gh repo clone CrystallyRains/90DaysOfDevOps
```

This is basically `git clone` but it picks HTTPS or SSH based on how you authenticated with `gh`.

### View repo details

```bash
gh repo view CrystallyRains/90DaysOfDevOps
```

Shows the README, description, and basic info right in the terminal.

```bash
gh repo view CrystallyRains/90DaysOfDevOps --web
```

Opens the repo in your default browser.

### List all your repos

```bash
gh repo list CrystallyRains --limit 30
```

I have 58 repos, so it showed the first 30. Increase `--limit` if you want more.

### Delete a repo

```bash
gh repo delete test-gh-cli --yes
```

**Gotcha:** This failed the first time with a 403 error saying I need `delete_repo` scope. Fixed it with:

```bash
gh auth refresh -h github.com -s delete_repo
```

Then the delete worked.

---

## 3. Issues

### Create an issue

```bash
gh issue create --repo CrystallyRains/90DaysOfDevOps \
  --title "Day 26: Test issue from gh CLI" \
  --body "This issue was created entirely from the terminal." \
  --label "documentation"
```

**Gotcha:** My first attempt failed because issues were **disabled by default on my fork**. GitHub does this for forks so you don't accidentally spam the original repo with issues.

I had to go to my fork's Settings on GitHub and tick the "Issues" checkbox. After that, it worked and created issue #1.

### List issues

```bash
gh issue list --repo CrystallyRains/90DaysOfDevOps
```

### View a specific issue

```bash
gh issue view 1 --repo CrystallyRains/90DaysOfDevOps
```

### Close an issue

```bash
gh issue close 1 --repo CrystallyRains/90DaysOfDevOps
```

### How could this be used in scripts or automation?

- Auto-create an issue when a CI/CD pipeline fails
- Bulk-close old/stale issues with a cron job
- Parse issue data as JSON (`--json` flag) and feed it into Slack or a dashboard

---

## 4. Pull Requests

This was the most interesting part — and where I made a mistake.

### The full flow

```bash
# 1. Create a branch
git checkout -b day26-gh-cli-notes

# 2. Make a change
echo "# Day 26 Notes" > 2026/day-26/day-26-notes.md

# 3. Commit and push
git add .
git commit -m "Add Day 26 GitHub CLI notes"
git push -u origin day26-gh-cli-notes

# 4. Create PR from terminal
gh pr create --fill
```

`--fill` auto-fills the PR title and description from your commit messages. Pretty neat.

### **BIG MISTAKE I MADE**

My first PR went to the **original upstream repo** (`TrainWithShubham/90DaysOfDevOps`) instead of my fork. It created PR #761 on the original repo.

**Why?** Because when you clone a fork, `gh` sets the upstream repo as the default for PRs.

**How I fixed it:**

```bash
# Close the wrong PR
gh pr close 761 --repo TrainWithShubham/90DaysOfDevOps

# Tell gh to always use MY fork as the default
gh repo set-default CrystallyRains/90DaysOfDevOps
```

After setting the default, my second PR went to my own fork (#2) and everything was fine.

### List PRs

```bash
gh pr list
```

### View PR details

```bash
gh pr view 2
```

Shows status, reviewers, checks, and a summary of changes.

### Merge a PR

```bash
gh pr merge 2 --squash --delete-branch
```

This:
- Squashes all commits into one
- Merges it into master
- Deletes the branch both locally and on GitHub

All in one command. Felt pretty good not touching the browser.

### What merge methods does `gh pr merge` support?

| Flag | What it does |
|------|-------------|
| `--merge` | Normal merge, keeps all commits |
| `--squash` | Squashes everything into one commit |
| `--rebase` | Rebases then fast-forwards |
| `--delete-branch` | Deletes the branch after merging |

### How to review someone else's PR using `gh`?

```bash
# Pull their branch locally to test it
gh pr checkout <pr-number>

# See the diff
gh pr diff <pr-number>

# Approve it
gh pr review <pr-number> --approve --body "LGTM"

# Leave a comment
gh pr comment <pr-number> --body "Check line 42"
```

---

## 5. GitHub Actions Preview

Since I haven't done the GitHub Actions days yet (coming up at Day 38), this was just a sneak peek.

### List workflow runs on a public repo

```bash
gh run list --repo actions/checkout
```

Shows status (pass/fail), workflow name, branch, event type, and run ID.

### View a specific run

```bash
gh run view 32631582718 --repo actions/checkout
```

### How could this help in CI/CD?

- Trigger a workflow manually: `gh workflow run <file.yml>`
- Watch live logs: `gh run watch <run-id>`
- Re-run failed jobs: `gh run rerun <run-id> --failed`
- Download build artifacts: `gh run download <run-id>`

Basically lets you debug CI issues without constantly refreshing the GitHub web UI.

---

## 6. Random Useful Tricks

### Raw GitHub API calls

```bash
gh api repos/CrystallyRains/90DaysOfDevOps --jq '.stargazers_count'
# Output: 0
```

The `--jq` flag lets you filter the JSON response. Useful for scripting.

### Create a release

```bash
gh release create v1.0.0 --notes "First stable release"
```

Created a release on my fork just to try it. Worked instantly.

### Create aliases for commands you use often

```bash
# I already had 'co' taken, so I overwrote it
gh alias set co --clobber "pr checkout"

# New alias
gh alias set pv "pr view"
```

Now I can just type:

```bash
gh co 5    # checks out PR #5
gh pv 2    # views PR #2
```

### Search repos

```bash
gh search repos "kubernetes terraform" --stars=">100" --language=HCL
```

Found 4 repos. Pretty powerful for discovery without opening GitHub.

---

## My Favorite Commands from Today

1. **`gh pr create --fill`** — creating a PR without writing a title or description manually
2. **`gh pr merge <num> --squash --delete-branch`** — merge + cleanup in one shot
3. **`gh repo set-default`** — saved me from sending more PRs to the wrong repo
4. **`gh alias set`** — feels like building my own custom tool

---

## Quick Cheat Sheet

```bash
# Auth
gh auth login
gh auth status
gh auth refresh -s delete_repo

# Repos
gh repo create <name> --public --add-readme
gh repo clone <owner>/<repo>
gh repo view --web
gh repo list <owner>
gh repo delete <name> --yes

# Issues
gh issue create --title "..." --body "..." --label "..."
gh issue list
gh issue view <num>
gh issue close <num>

# PRs
gh pr create --fill
gh pr list
gh pr view <num>
gh pr checkout <num>
gh pr diff <num>
gh pr merge <num> --squash --delete-branch

# Actions
gh run list
gh run view <id>
gh workflow run <file>

# Utils
gh api <endpoint> --jq '<filter>'
gh release create <tag> --notes "..."
gh alias set <name> <command>
gh search repos "<query>"
```

---

## Stuff That Tripped Me Up

| Problem | Why it happened | Fix |
|---------|----------------|-----|
| `gh repo delete` gave 403 | Token didn't have `delete_repo` scope | `gh auth refresh -h github.com -s delete_repo` |
| Issues were disabled | Forks disable issues by default | Enable in repo Settings |
| PR went to upstream repo | `gh` defaults to upstream on forks | `gh repo set-default CrystallyRains/90DaysOfDevOps` |
| `gh auth whoami` not found | That command literally doesn't exist | Use `gh auth status` |

---

*Day 26 done. Terminal feels way more powerful now.*
