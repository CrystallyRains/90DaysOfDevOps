# Day 39 - What is CI/CD?

## Goal

Understand why CI/CD exists, the difference between Continuous
Integration, Continuous Delivery, and Continuous Deployment, and the
basic anatomy of a CI/CD pipeline.

CI/CD is a **practice**, not a single tool. Tools such as GitHub
Actions, Jenkins, GitLab CI, and CircleCI can be used to implement
CI/CD.

------------------------------------------------------------------------

## Task 1: The Problem

Imagine a team of 5 developers working on the same repository and
manually deploying changes to production.

### 1. What can go wrong?

When multiple developers are making different changes, it can become
difficult to know exactly what version of the code is being deployed.

Someone might deploy an incomplete change, overwrite another developer's
changes, miss a configuration step, or deploy code that was not properly
tested.

This can result in:

-   Inconsistent environments
-   Failed deployments
-   Bugs in production
-   Application downtime
-   The application crashing in production
-   More time spent on repetitive manual work

### 2. What does "it works on my machine" mean?

"It works on my machine" means the application works correctly in one
developer's local environment but may fail when it runs somewhere else.

The environments can differ because of:

-   Different operating systems
-   Missing dependencies
-   Different dependency versions
-   Different environment variables
-   Different runtime versions
-   Different system or network configuration

For example, an application may work on a developer's laptop because a
required dependency is already installed, but fail in another
environment where that dependency is missing.

This becomes a real production problem when users cannot access or use
the application.

### 3. How many times a day can a team safely deploy manually?

There is no fixed number of manual deployments that is considered safe.

A team can technically deploy multiple times a day, but every manual
deployment requires human effort and introduces opportunities for
mistakes and inconsistency.

As deployment frequency increases, manually repeating steps such as
testing, building, configuring, and deploying becomes harder to manage
reliably.

**CI/CD helps solve this by automating repetitive and error-prone parts
of the software delivery process.**

------------------------------------------------------------------------

## Task 2: CI vs CD

The easiest way to remember the difference is:

``` text
CI = Integrate and Test
Continuous Delivery = Keep it Ready to Release
Continuous Deployment = Release Automatically
```

### 1. Continuous Integration (CI)

Developers frequently merge code changes into a shared repository, often
multiple times a day. Automated builds and tests run against those
changes to catch bugs and integration problems early.

**Real-world example:** A developer pushes code to GitHub. A GitHub
Actions workflow automatically checks out the code, installs
dependencies, builds the application, and runs automated tests.

### 2. Continuous Delivery

Continuous Delivery extends CI by automatically building, testing, and
preparing the application for release. The software is kept in a
**deployable state**, but a human may still need to approve or trigger
the production release.

**Real-world example:** After the application passes CI tests, the
pipeline creates a Docker image and prepares it for deployment. A team
member approves the production deployment when ready.

### 3. Continuous Deployment

Continuous Deployment goes one step further. Every change that
successfully passes the required pipeline checks is automatically
deployed to production without a manual approval step.

Teams generally use this when they have strong automated testing,
monitoring, and confidence in their deployment process.

**Real-world example:** A developer pushes a change, all automated tests
pass, and the pipeline automatically deploys the new version to
production.

### Quick Comparison

  -----------------------------------------------------------------------
  Practice                Main idea               Production deployment
  ----------------------- ----------------------- -----------------------
  Continuous Integration  Integrate code and test Not necessarily
                          it frequently           

  Continuous Delivery     Keep software ready to  Usually requires manual
                          release                 approval

  Continuous Deployment   Automatically release   Automatic
                          successful changes      
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## Task 3: Pipeline Anatomy

A CI/CD pipeline is made up of several parts. These parts describe what
starts the pipeline, how work is organized, and where that work runs.

### Trigger

The event that starts the pipeline.

Examples:

-   Developer pushes code
-   Pull request is opened or updated
-   Scheduled event
-   Manual workflow trigger

### Stage

A logical phase of the pipeline that groups related work.

Examples:

-   Build
-   Test
-   Deploy

### Job

A unit of work inside a stage. A job contains the commands and actions
required to complete a particular task.

For example, a Test stage could contain a job called `run-tests`.

### Step

A single command or action inside a job.

Examples:

``` bash
npm install
npm test
docker build
```

### Runner

The machine or execution environment where a job runs.

For example, GitHub Actions can run a job on a GitHub-hosted Ubuntu
runner.

### Artifact

A file or output produced by a job that can be used later in the
pipeline or downloaded for further use.

Examples:

-   Compiled application
-   Test report
-   Docker image
-   Packaged application

### Pipeline Structure

``` text
Trigger
   |
   v
Stage
   |
   +--> Job
          |
          +--> Step
          +--> Step
          +--> Step
                 |
                 v
              Runner
                 |
                 v
              Artifact
```

The important distinction is that **Stage, Job, and Step describe the
structure of the work, while the Runner is where the job actually
executes.**

------------------------------------------------------------------------

## Task 4: Draw a Pipeline

### Scenario

A developer pushes code to GitHub. The application is tested, built into
a Docker image, and deployed to a staging server.

### Pipeline

``` text
Developer
    |
    | Push code
    v
GitHub
    |
    | Trigger
    v
+-----------------------+
| Stage 1: Build & Test |
|                       |
| Checkout code         |
| Install dependencies  |
| Run tests             |
| Build application     |
+-----------------------+
    |
    v
+--------------------------+
| Stage 2: Docker Build    |
|                          |
| Build Docker image       |
| Tag image                |
| Push image to registry   |
+--------------------------+
    |
    v
+--------------------------+
| Stage 3: Deploy Staging  |
|                          |
| Pull Docker image        |
| Run container            |
+--------------------------+
    |
    v
Staging Server
```

### What this pipeline demonstrates

The pipeline has three logical stages:

1.  **Build and Test:** Verify that the application can be built and
    that the tests pass.
2.  **Docker Build:** Package the application into a Docker image and
    push it to a container registry.
3.  **Deploy to Staging:** Pull the image onto the staging server and
    run the application as a container.

A failure in an earlier stage should normally prevent the pipeline from
continuing to the next stage.

------------------------------------------------------------------------

## Task 5: Explore in the Wild

I explored a GitHub Actions workflow for managing stale issues and pull
requests.

### Workflow

`Manage stale issues and PRs`

The workflow uses:

``` yaml
name: (Shared) Manage stale issues and PRs
```

### 1. What triggers it?

It has two triggers:

``` yaml
on:
  schedule:
    - cron: '0 * * * *'
  workflow_dispatch:
```

-   **Schedule:** Runs automatically every hour.
-   **workflow_dispatch:** Allows the workflow to be started manually
    from GitHub.

### 2. How many jobs does it have?

It has **1 job**:

``` yaml
jobs:
  stale:
```

The job runs on:

``` yaml
runs-on: ubuntu-latest
```

This means the job executes on a GitHub-hosted Ubuntu runner.

### 3. What does it do?

The workflow uses `actions/stale@v9` to automatically manage inactive
issues and pull requests.

From the configuration:

-   Issues and PRs become stale after **90 days of inactivity**.
-   Stale issues and PRs are closed after another **7 days** of
    inactivity.
-   The workflow adds the `Resolution: Stale` label.
-   It posts a message when an issue or PR is marked as stale.
-   Certain labels are excluded from stale processing.
-   It can perform up to **100 operations per run**.

### Workflow Structure

``` text
Trigger
   |
   +--> Hourly schedule
   |
   +--> Manual trigger
          |
          v
      Job: stale
          |
          v
   Ubuntu Runner
          |
          v
   actions/stale@v9
          |
          v
Manage inactive Issues and PRs
```

### What I learned

GitHub Actions workflows can automate more than application builds and
deployments. They can also automate repository maintenance tasks.

A workflow essentially defines:

**when to run, what environment to use, and what actions to perform.**

------------------------------------------------------------------------

## Key Takeaways

### CI/CD solves a real problem

Without automation, teams have to repeatedly perform tasks such as
testing, building, packaging, and deploying manually. This increases the
chance of human error and makes frequent releases harder to manage.

### CI

**Integrate code frequently and test it automatically.**

### Continuous Delivery

**Keep the software in a deployable state and ready for release.**

### Continuous Deployment

**Automatically deploy successful changes without a manual production
approval.**

### Pipeline Anatomy

``` text
Trigger
   ↓
Stage
   ↓
Job
   ↓
Step
   ↓
Runner executes the job
   ↓
Artifact may be produced
```

### Important

A pipeline failing is not necessarily a problem. A failed build or test
can be CI/CD doing its job by catching a problem before it reaches the
next environment.

------------------------------------------------------------------------

## Day 39 Aha Moment

**CI/CD is not just about automating deployment. It is about creating a
repeatable and reliable process for moving code from development toward
release, while catching problems as early as possible.**
