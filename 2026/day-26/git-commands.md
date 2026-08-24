## GitHub CLI (`gh`) — Day 26

### Authentication
| Command | Description |
|---------|-------------|
| `gh auth login` | Log in to GitHub |
| `gh auth status` | Check auth status |
| `gh auth refresh -h github.com -s delete_repo` | Add extra scopes |

### Repositories
| Command | Description |
|---------|-------------|
| `gh repo create &lt;name&gt; --public --add-readme` | Create a new repo |
| `gh repo clone &lt;owner&gt;/&lt;repo&gt;` | Clone a repo |
| `gh repo view --web` | Open repo in browser |
| `gh repo delete &lt;name&gt; --yes` | Delete a repo |

### Issues
| Command | Description |
|---------|-------------|
| `gh issue create --title "..." --body "..." --label "..."` | Create an issue |
| `gh issue list` | List open issues |
| `gh issue view &lt;num&gt;` | View an issue |
| `gh issue close &lt;num&gt;` | Close an issue |

### Pull Requests
| Command | Description |
|---------|-------------|
| `gh pr create --fill` | Create a PR (auto-filled) |
| `gh pr list` | List open PRs |
| `gh pr view &lt;num&gt;` | View PR details |
| `gh pr checkout &lt;num&gt;` | Check out a PR branch |
| `gh pr merge &lt;num&gt; --squash --delete-branch` | Merge and cleanup |
| `gh pr diff &lt;num&gt;` | Show PR diff |

### Actions & Workflows
| Command | Description |
|---------|-------------|
| `gh run list` | List workflow runs |
| `gh run view &lt;id&gt;` | View a specific run |

### Aliases & Shortcuts
| Command | Description |
|---------|-------------|
| `gh alias set &lt;name&gt; &lt;expansion&gt;` | Create a shortcut |
| `gh alias set co --clobber "pr checkout"` | Overwrite existing alias |
| `gh api &lt;endpoint&gt;` | Make raw API calls |
| `gh search repos &lt;query&gt;` | Search GitHub repos |
| `gh repo set-default &lt;owner&gt;/&lt;repo&gt;` | Set default repo for PRs |
