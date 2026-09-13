# Day 45 -- Docker CI/CD with GitHub Actions

## Goal

Build a CI/CD pipeline that automatically builds a Docker image, pushes
it to Docker Hub, and deploys the application to an AWS EC2 instance.

## Architecture

``` text
GitHub
   ↓
GitHub Actions
   ↓
Lint
   ↓
Docker Build
   ↓
Docker Hub
   ↓
AWS EC2
   ↓
Docker Compose
   ↓
Running Application
```

## What I Built

The pipeline is divided into three stages:

1.  **Code validation**
    -   GitHub Actions runs the lint workflow first.
    -   The build and deployment stages depend on the lint stage
        succeeding.
2.  **Docker CI**
    -   GitHub Actions checks out the repository.
    -   Docker Buildx builds the application image.
    -   The workflow logs in to Docker Hub using GitHub Actions secrets.
    -   The image is pushed to Docker Hub.
3.  **Docker CD**
    -   A self-hosted GitHub Actions runner runs on the EC2 instance.
    -   The deployment workflow logs in to Docker Hub.
    -   EC2 pulls the latest Docker image.
    -   Docker Compose starts the updated application.

## Workflow Structure

The main workflow coordinates the reusable workflows:

``` yaml
name: CI/CD Deployment

on:
  push:

jobs:
  code:
    uses: ./.github/workflows/lint.yml

  build-and-push:
    needs: code
    secrets: inherit
    uses: ./.github/workflows/ci.yml

  deploy:
    needs: build-and-push
    secrets: inherit
    uses: ./.github/workflows/cd.yml
```

This keeps the lint, CI and CD stages separate and makes the overall
pipeline easier to manage.

## CI Workflow

The CI workflow builds the Docker image and pushes it to Docker Hub.

``` yaml
name: Docker Build & Push

on:
  workflow_call:

jobs:
  docker-build:
    runs-on: self-hosted

    steps:
      - name: Code Checkout
        uses: actions/checkout@v7

      - name: Docker Login
        uses: docker/login-action@v4
        with:
          username: ${{ vars.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v4

      - name: Build and Push
        uses: docker/build-push-action@v7
        with:
          push: true
          tags: ${{ vars.DOCKERHUB_USERNAME }}/e-commerce-python:latest
```

### Important Points

-   `actions/checkout` gets the repository code.
-   `docker/login-action` authenticates with Docker Hub.
-   `docker/setup-buildx-action` sets up Docker Buildx for the build.
-   `docker/build-push-action` builds and pushes the image.
-   The image is tagged as `latest`.
-   Docker Engine was already installed on the EC2 self-hosted runner,
    so an additional Docker installation step was not required.

## CD Workflow

The CD workflow deploys the image to EC2.

``` yaml
name: Deploy Application

on:
  workflow_call:

jobs:
  deploy:
    runs-on: self-hosted

    steps:
      - name: Code Checkout
        uses: actions/checkout@v7

      - name: Docker Login
        uses: docker/login-action@v4
        with:
          username: ${{ vars.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Pull latest Docker image
        run: docker compose pull

      - name: Run Docker Compose
        run: docker compose up -d
```

## Docker Compose

The EC2 instance uses the Docker image published by the CI workflow.

``` yaml
services:
  app:
    image: snigdhach/e-commerce-python:latest
    ports:
      - "80:3000"
    volumes:
      - sqlite_data:/app/data
    restart: unless-stopped

volumes:
  sqlite_data:
```

The named volume keeps the SQLite database data outside the container
filesystem.

## Self-Hosted Runner

A GitHub Actions self-hosted runner was registered on the EC2 instance.

The runner allows GitHub Actions jobs to execute directly on the EC2
environment.

The runner was used for:

-   Docker image build
-   Docker image push
-   Deployment
-   Docker Compose commands

The runner was configured under:

``` bash
~/actions-runner
```

It can be started with:

``` bash
./run.sh
```

## End-to-End Flow

The complete deployment process is:

``` text
1. Push code to GitHub
        ↓
2. GitHub Actions starts the pipeline
        ↓
3. Lint workflow runs
        ↓
4. Docker image is built
        ↓
5. Image is pushed to Docker Hub
        ↓
6. Deployment job runs on the EC2 self-hosted runner
        ↓
7. EC2 pulls the latest Docker image
        ↓
8. Docker Compose starts the application
        ↓
9. Application runs on EC2
```

## Result

The complete CI/CD pipeline ran successfully:

``` text
code / lint          → Succeeded
build-and-push       → Succeeded
deploy               → Succeeded
```

The Docker image was pushed to Docker Hub and the application was
deployed to the EC2 instance using Docker Compose.

## Key Takeaways

-   GitHub Actions can automate the complete Docker deployment workflow.
-   Reusable workflows can separate CI and CD responsibilities.
-   Docker Hub provides a registry for storing and distributing images.
-   A self-hosted runner allows GitHub Actions to execute jobs in your
    own infrastructure.
-   Docker Compose can be used to run the published image on the
    deployment server.
-   The complete flow removes the need to manually build, push and
    deploy the application after every code change.

## Verification

### Check Docker image

``` bash
docker images
```

### Check running containers

``` bash
docker ps
```

### Check Docker Compose

``` bash
docker compose ps
```

### Pull the latest image

``` bash
docker compose pull
```

### Start the application

``` bash
docker compose up -d
```

### View logs

``` bash
docker compose logs -f
```

## Final Flow

``` text
Code Push
   ↓
GitHub Actions
   ↓
Lint
   ↓
Docker Build
   ↓
Docker Hub
   ↓
EC2 Self-Hosted Runner
   ↓
Docker Compose
   ↓
Running Container
```
