# Day 30 – Docker Images & Container Lifecycle

## Overview

Today I went deeper into Docker by understanding **images, image layers, and the container lifecycle**.

The main idea:

> **An image is a template, while a container is an instance created from that image.**

---

## 1. Docker Images

### What is a Docker Image?

A Docker image is a **read-only template** used to create containers.

It contains the files, libraries, dependencies, configuration, and instructions needed to run an application.

```text
Docker Image
     ↓
   Template
     ↓
  Container
     ↓
Running Application
```

### Pulling Images

I worked with common images such as Nginx, Ubuntu, Alpine, and Hello World.

```bash
docker pull nginx
docker pull ubuntu
docker pull alpine
docker pull hello-world
```

### List Images

```bash
docker images
```

This shows details such as:

- Repository
- Tag
- Image ID
- Creation time
- Size

### Inspect an Image

```bash
docker inspect nginx
```

This provides detailed information about the image, including configuration, architecture, environment variables, entrypoint, command, and filesystem information.

### Remove an Image

```bash
docker rmi <image>
```

An image should only be removed when it is no longer required.

---

## 2. Ubuntu vs Alpine

Ubuntu and Alpine are both Linux-based images, but their sizes are very different.

### Ubuntu

- General-purpose Linux distribution
- Includes more packages and utilities
- Larger image size
- Useful when a more complete environment is required

### Alpine

- Minimal Linux distribution
- Designed to be lightweight
- Uses BusyBox and musl libc
- Much smaller image size

```text
Ubuntu
├── More packages and utilities
├── General-purpose
└── Larger

Alpine
├── Minimal
├── Lightweight
└── Smaller
```

A smaller image is not automatically better. The choice depends on what the application needs.

---

# 3. Docker Image Layers

Docker images are built using **multiple layers** instead of being one large block.

A simplified example:

```text
Base Image
    ↓
Install packages
    ↓
Copy application
    ↓
Add configuration
    ↓
Final Image
```

Each layer represents a change made while building the image.

### View Image History

```bash
docker image history nginx
```

This shows the history of the image and the layers involved in building it.

Some entries may show `0B`. This can happen when an instruction changes image configuration or metadata without adding filesystem data.

Examples include:

```dockerfile
CMD
ENTRYPOINT
ENV
EXPOSE
```

---

## Why Does Docker Use Layers?

### Reusability

Different images can share common layers.

```text
          Base Layer
          /        \
         ↓          ↓
      Image A    Image B
```

Docker can reuse the common layer instead of storing it separately.

### Caching

Docker can reuse unchanged layers during image builds.

```text
Layer 1 → Cached
Layer 2 → Cached
Layer 3 → Changed
Layer 4 → Rebuilt
```

This makes builds faster.

### Storage Efficiency

Shared layers reduce unnecessary duplication when multiple images use the same base or other common layers.

---

# 4. Image vs Container

This is one of the most important concepts from today.

### Image

An image is the **template**.

### Container

A container is an **instance created from that image**.

```text
              Docker Image
                (Template)
                    ↓
                docker run
                    ↓
                 Container
                (Instance)
                    ↓
                Application
```

The same image can be used to create multiple containers.

```text
              Nginx Image
              /         \
             ↓           ↓
      Container A   Container B
```

---

# 5. Container Lifecycle

A container can move through several states.

```text
Create
  ↓
Created
  ↓
Start
  ↓
Running
  ↓
Pause
  ↓
Paused
  ↓
Unpause
  ↓
Running
  ↓
Stop
  ↓
Exited
  ↓
Restart
  ↓
Running
  ↓
Kill
  ↓
Exited
  ↓
Remove
  ↓
Deleted
```

I used `docker ps -a` to observe containers in different states.

```bash
docker ps -a
```

Unlike `docker ps`, which shows running containers, `docker ps -a` shows both running and stopped containers.

---

## Create

`docker create` creates a container without starting it.

```bash
docker create --name test-container nginx
```

The container exists, but it is not running.

---

## Start

```bash
docker start test-container
```

Starts an existing container.

```text
Created → Running
```

---

## Pause

```bash
docker pause test-container
```

Temporarily pauses the processes inside the container.

---

## Unpause

```bash
docker unpause test-container
```

Resumes the paused processes.

---

## Stop

```bash
docker stop test-container
```

Stops the container gracefully.

The container still exists and can be started again.

```text
Running
   ↓
Stopped
   ↓
Container still exists
```

---

## Restart

```bash
docker restart test-container
```

Restarts the container.

---

## Kill

```bash
docker kill test-container
```

Immediately terminates the container's main process.

### Stop vs Kill

```text
docker stop
→ Graceful shutdown

docker kill
→ Immediate termination
```

---

## Remove

```bash
docker rm test-container
```

Removes the container.

Removing a container does **not** automatically remove the image used to create it.

```text
nginx image
     ↓
nginx container
     ↓
docker rm
     ↓
Container removed

nginx image
     ↓
Still available
```

---

# 6. Working with a Running Container

## Detached Mode

I ran Nginx in detached mode so it could continue running in the background.

```bash
docker run -d --name my-nginx -p 80:80 nginx
```

Here:

- `-d` → detached mode
- `--name my-nginx` → custom container name
- `-p 80:80` → maps host port 80 to container port 80

---

## View Logs

```bash
docker logs my-nginx
```

This displays the logs generated by the container.

Logs are useful for monitoring and troubleshooting.

### Follow Logs

```bash
docker logs -f my-nginx
```

The `-f` option follows the logs in real time.

Press `Ctrl + C` to stop following the logs.

---

## Execute a Command Inside a Container

To open an interactive shell:

```bash
docker exec -it my-nginx /bin/bash
```

`-i` keeps the session interactive and `-t` allocates a terminal.

Inside the container, I can run normal Linux commands such as:

```bash
pwd
ls
```

Exit with:

```bash
exit
```

### Run a Single Command

I don't always need to enter the container.

```bash
docker exec my-nginx ls
```

This runs `ls` inside the container and returns the output to the terminal.

---

# 7. Inspecting a Container

```bash
docker inspect my-nginx
```

This provides detailed information about the container, including:

- Container state
- Image used
- Network configuration
- IP address
- Port mappings
- Mounts
- Environment variables
- Runtime configuration

`docker inspect` is especially useful when troubleshooting a container.

---

# 8. Docker Cleanup

Docker resources can accumulate while working with containers and images.

### Check Disk Usage

```bash
docker system df
```

This shows Docker's disk usage, including images, containers, volumes, and build cache.

### Remove Stopped Containers

```bash
docker container prune
```

Removes stopped containers after confirmation.

### Remove Unused Resources

```bash
docker system prune
```

Removes unused Docker resources.

Cleanup commands should be used carefully because they can remove resources that are no longer being used.

---

# 9. Important Commands

| Command | Purpose |
|---|---|
| `docker pull` | Download an image |
| `docker images` | List local images |
| `docker inspect` | View detailed information |
| `docker image history` | View image history and layers |
| `docker rmi` | Remove an image |
| `docker create` | Create a container without starting it |
| `docker run` | Create and start a container |
| `docker ps` | List running containers |
| `docker ps -a` | List all containers |
| `docker start` | Start a container |
| `docker pause` | Pause a running container |
| `docker unpause` | Resume a paused container |
| `docker stop` | Gracefully stop a container |
| `docker restart` | Restart a container |
| `docker kill` | Immediately terminate a container |
| `docker rm` | Remove a container |
| `docker logs` | View container logs |
| `docker logs -f` | Follow logs in real time |
| `docker exec` | Run a command inside a container |
| `docker container prune` | Remove stopped containers |
| `docker system df` | Check Docker disk usage |
| `docker system prune` | Remove unused Docker resources |

---

# Key Takeaways

- A Docker **image is a template** and a **container is an instance** created from that template.
- Docker images are made up of multiple layers.
- Layers allow Docker to reuse data, improve build speed through caching, and reduce duplication.
- Ubuntu provides a more complete environment, while Alpine focuses on being lightweight.
- `docker create` creates a container without starting it.
- `docker stop` stops a container but does not remove it.
- `docker rm` removes the container.
- `docker kill` immediately terminates the container's main process.
- `docker logs` helps with monitoring and troubleshooting.
- `docker exec` allows commands to be run inside a running container.
- `docker inspect` provides detailed information about a container.
- `docker system df` helps track Docker disk usage.
- Cleanup commands help manage unused Docker resources.

---

# Conclusion

Day 30 helped me move beyond simply running Docker containers.

I now have a clearer understanding of the relationship between **images and containers**, how **image layers and caching** work, and how a container moves through its lifecycle.

The overall workflow makes more sense now:

```text
Docker Image
     ↓
Image Layers
     ↓
Create Container
     ↓
Start
     ↓
Running
     ↓
Logs / Exec / Inspect
     ↓
Stop / Restart / Kill
     ↓
Remove
     ↓
Cleanup
```

This gives me a solid foundation for the next Docker topics, where I can start building and customizing my own images.

---

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
