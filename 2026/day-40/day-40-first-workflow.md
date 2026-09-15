# Day 40: First GitHub Actions Workflow

## Goal

Understand the basics of GitHub Actions by creating a simple workflow, running it, adding steps, and intentionally breaking it to understand pipeline failures.

## Task 1: Create the Repository

Created a public GitHub repository called `github-actions-practice`.

Created the workflow directory:

```text
.github/
└── workflows/
```

GitHub Actions workflow files are stored inside `.github/workflows/`.

## Task 2: Create the First Workflow

Created `.github/workflows/hello.yml`.

The workflow runs on a push to the `main` branch, contains one job called `greet`, runs on an `ubuntu-latest` runner, checks out the repository using `actions/checkout@v7`, and prints a greeting.

```yaml
name: Greet and get code

on:
  push:
    branches: [main]

jobs:
  greet:
    runs-on: ubuntu-latest
    steps:
      - name: Code checkout
        uses: actions/checkout@v7

      - name: Greet with hello
        run: echo "Hello from GitHub Actions!"
```

The workflow completed successfully and printed:

```text
Hello from GitHub Actions!
```

## Task 3: Understand the Anatomy

### `name:`

Defines the name of the workflow displayed in the GitHub Actions UI.

### `on:`

Defines the event that triggers the workflow.

```yaml
on:
  push:
    branches: [main]
```

Here, a push to `main` triggers the workflow.

### `jobs:`

Defines the jobs or units of work performed by the workflow.

```yaml
jobs:
  greet:
```

A workflow can contain multiple jobs such as build, test, Docker image build, or deployment.

### `runs-on:`

Defines the runner environment where the job executes.

```yaml
runs-on: ubuntu-latest
```

Here, the job runs on a GitHub-hosted Ubuntu runner.

### `steps:`

Defines the individual steps inside a job. A job can contain multiple steps.

### `uses:`

Specifies an existing GitHub Action to use in a step.

```yaml
uses: actions/checkout@v7
```

### `run:`

Executes a shell command on the runner.

```yaml
run: echo "Hello from GitHub Actions!"
```

### `name:` on a step

Gives an individual step a readable name, making it easier to identify in the Actions UI.

### Quick Revision

```text
name       → Workflow or step name
on         → Workflow trigger
jobs       → Jobs or units of work
runs-on    → Runner environment
steps      → Individual steps inside a job
uses       → Existing GitHub Action
run        → Shell command to execute
```

Important distinction:

```text
Job
  ↓
Steps
  ├── Action
  ├── Command
  └── Command
```

A job is a unit of work, while steps are the individual actions or commands inside that job.

## Task 4: Add More Steps

Updated `hello.yml` to print the current date and time, the branch that triggered the workflow, the files in the repository, and the runner operating system.

Final workflow:

```yaml
name: Greet and get code

on:
  push:
    branches: [main]

jobs:
  greet:
    runs-on: ubuntu-latest
    steps:
      - name: Code checkout
        uses: actions/checkout@v7

      - name: Greet with hello
        run: echo "Hello from GitHub Actions!"

      - name: Print current date and time
        run: echo "The current date and time is $(date)."

      - name: Print the branch that triggered the workflow
        run: echo "The branch that triggered this run is ${{ github.ref_name }}"

      - name: List the files in the repo
        run: ls -la

      - name: Print the runner OS
        run: echo "The operating system of this runner is ${{ runner.os }}"
```

The workflow completed successfully.

### Output Observed

```text
Hello from GitHub Actions!
The current date and time is Tue Sep 15 13:12:36 UTC 2026.
The branch that triggered this run is main
The operating system of this runner is Linux
```

The repository files were successfully listed using:

```bash
ls -la
```

### GitHub Actions Expressions vs Shell Commands

GitHub Actions expression:

```yaml
${{ github.ref_name }}
```

Provides the name of the branch that triggered the workflow.

GitHub Actions expression:

```yaml
${{ runner.os }}
```

Provides the operating system of the runner.

Linux shell command substitution:

```bash
$(date)
```

Executes the `date` command on the runner.

```text
${{ ... }} → GitHub Actions expression
$(...)      → Shell command substitution
run:        → Executes a shell command on the runner
```

## Task 5: Break It On Purpose

Added a step that intentionally fails:

```yaml
- name: Intentionally fail the workflow
  run: exit 1
```

The workflow was pushed and the Actions run was observed.

The failing step showed:

```text
Run exit 1

Error: Process completed with exit code 1.
```

The step was marked as failed and the overall workflow failed.

### What Does a Failed Pipeline Look Like?

The GitHub Actions UI shows the workflow as **failed**, and the failing step is marked accordingly.

Example:

```text
✓ Code checkout
✓ Greet with hello
✓ Print current date and time
✓ Print the branch that triggered the workflow
✓ List the files in the repo
✓ Print the runner OS
✗ Intentionally fail the workflow
```

Steps after a failed step are normally skipped unless configured otherwise.

### How to Read the Error

Start with the step marked as failed. Look at the command that was executed and the error message immediately below it.

In this example:

```text
Run exit 1
Error: Process completed with exit code 1.
```

The command `exit 1` deliberately returned a non-zero exit code, so GitHub Actions treated the step as failed.

### Exit Codes

```text
exit 0 → success
exit 1 → failure
```

More generally, an exit code of `0` indicates success, while a non-zero exit code indicates failure.

### Real Troubleshooting Example

During Task 4, a previous run failed because the command was written as:

```bash
ls-la
```

instead of:

```bash
ls -la
```

The runner reported:

```text
ls-la: command not found
Error: Process completed with exit code 127.
```

This showed that GitHub Actions executes the command on the runner and reports the shell error when the command fails.

## Final Learning

The basic GitHub Actions workflow structure can be remembered as:

```text
Workflow
   ↓
Trigger
   ↓
Job
   ↓
Steps
   ↓
Actions / Commands
```

A GitHub Actions workflow is a YAML file stored in `.github/workflows/`.

The workflow defines when it should run, what jobs should execute, which runner should execute them, and what steps each job should perform.

A failed command produces a non-zero exit code, which can cause the job and workflow to fail. The Actions logs show the step and command where the failure occurred, making the pipeline easier to troubleshoot.
