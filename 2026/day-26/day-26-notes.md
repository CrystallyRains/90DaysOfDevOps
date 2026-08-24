# Day 26 – GitHub CLI (`gh`): Manage GitHub from Your Terminal

&gt; **Version used:** gh 2.98.0 (2026-08-20)  
&gt; **Installed via:** `brew install gh`  
&gt; **OS:** macOS (Apple Silicon)

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
