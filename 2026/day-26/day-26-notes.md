# Day 26 - GitHub CLI: Manage GitHub from Your Terminal

## Task 1: Install & Authenticate
- Installed `gh` via Homebrew: `brew install gh` → version 2.98.0
- Authenticated via browser device flow: `gh auth login`
- Verified with `gh auth status` — logged in as CrystallyRains
- Token scopes: `gist`, `read:org`, `repo`, `workflow`

**Q: What auth methods does `gh` support?**
&gt; Browser OAuth, PAT (classic & fine-grained), `GH_TOKEN` env var.

---

## Task 2: Working with Repositories
| Action | Command |
|--------|---------|
| Create repo | `gh repo create test-gh-cli --public --add-readme` |
| Clone repo | `gh repo clone CrystallyRains/90DaysOfDevOps` |
| View details | `gh repo view CrystallyRains/90DaysOfDevOps` |
| List repos | `gh repo list CrystallyRains --limit 30` |
| Open in browser | `gh repo view --web` |
| Delete repo | `gh repo delete test-gh-cli --yes` (needed `delete_repo` scope refresh) |

---

## Task 3: Issues
| Action | Command |
|--------|---------|
| Create issue | `gh issue create --title "..." --body "..." --label "documentation"` |
| List issues | `gh issue list` |
| View issue | `gh issue view 1` |
| Close issue | `gh issue close 1` |

**Note:** Issues were disabled on my fork by default. I had to enable them first.

**Q: How could `gh issue` be used in automation?**
&gt; Auto-create issues from CI failures, bulk-close stale issues, parse JSON for dashboards.

---

## Task 4: Pull Requests
| Action | Command |
|--------|---------|
| Create branch | `git checkout -b day26-gh-cli-notes` |
| Push branch | `git push -u origin day26-gh-cli-notes` |
| Create PR | `gh pr create --fill` |
| List PRs | `gh pr list` |
| View PR | `gh pr view 2` |
| Merge PR | `gh pr merge 2 --squash --delete-branch` |

**Important Learning:** My first PR went to the upstream `TrainWithShubham/90DaysOfDevOps` (#761) because `gh` defaulted to upstream. I closed it with `gh pr close 761 --repo TrainWithShubham/90DaysOfDevOps`, then set my fork as default with `gh repo set-default CrystallyRains/90DaysOfDevOps`, and recreated the PR on my fork (#2).

**Q: What merge methods does `gh pr merge` support?**
&gt; `--merge`, `--squash`, `--rebase`

**Q: How to review someone else's PR using `gh`?**
&gt; `gh pr checkout &lt;num&gt;` to test locally, `gh pr diff` to read diff, `gh pr review --approve` to approve.

---

## Task 5: GitHub Actions Preview
| Action | Command |
|--------|---------|
| List runs | `gh run list --repo actions/checkout` |
| View run | `gh run view 32631582718 --repo actions/checkout` |

**Q: How could `gh run` be useful in CI/CD?**
&gt; Trigger workflows, watch logs, rerun failures, download artifacts — all from terminal.

---

## Task 6: Useful Tricks
| Command | What I Did |
|---------|-----------|
| `gh api` | `gh api repos/CrystallyRains/90DaysOfDevOps --jq '.stargazers_count'` → returned `0` |
| `gh release create` | `gh release create v1.0.0 --notes "First stable release"` |
| `gh alias set` | `co` → `pr checkout`, `pv` → `pr view` |
| `gh search repos` | `gh search repos "kubernetes terraform" --stars="&gt;100" --language=HCL` |

---

## Favorite Command of the Day
&gt; `gh pr merge 2 --squash --delete-branch` — merging and cleaning up without touching the browser feels like real DevOps power.
