# Day 30 – Docker Images & Container Lifecycle

## Overview

Today I went one step deeper into Docker.

After learning how to run and interact with containers on Day 29, today's focus was on understanding **Docker images, image layers, and the complete container lifecycle**.

The main concepts covered today were:

- Docker images
- Image sizes and comparison
- Image inspection
- Image layers
- Image history
- Container lifecycle
- Running containers in detached mode
- Logs and real-time logs
- Executing commands inside containers
- Container inspection
- Docker cleanup and disk usage

---

# Task 1: Docker Images

## What is a Docker Image?

A Docker image is a **read-only template** used to create containers.

It contains the files, libraries, dependencies, configuration, and instructions required to run an application.

A simple way to understand it is:

```text
Docker Image
     ↓
Template
     ↓
Container
     ↓
Running Application
