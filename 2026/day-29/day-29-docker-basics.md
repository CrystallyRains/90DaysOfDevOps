# Day 29 – Introduction to Docker

## What I Learned

Today I started working with **Docker** and learned the basics of containers. I focused on understanding what containers are, how Docker works, and the basic commands used to create, run, stop, start, inspect, and interact with containers.

---

## 1. What is Docker?

**Docker** is a platform used to package and run applications inside **containers**.

A container contains the application along with the libraries, dependencies, and configuration it needs to run.

This helps make applications more consistent because the same container can run across different environments without needing to install everything manually.

### Why do we need containers?

Without containers, an application may work on one machine but fail on another because of differences in:

* Operating system
* Dependencies
* Libraries
* Runtime versions
* Configuration

Containers help solve this problem by packaging the required environment together with the application.

A simple way to think about it:

> **Container = Application + Dependencies + Configuration**

---

# 2. Containers vs Virtual Machines

Both containers and virtual machines provide isolated environments, but they work differently.

| Virtual Machine              | Container                              |
| ---------------------------- | -------------------------------------- |
| Includes a complete guest OS | Shares the host OS kernel              |
| Uses a hypervisor            | Uses a container engine such as Docker |
| Usually heavier              | Lightweight                            |
| Takes more resources         | Uses fewer resources                   |
| Usually slower to start      | Starts very quickly                    |
| Strong OS-level isolation    | Process-level isolation                |

### Simple example

A VM is like having **another complete computer inside your computer**.

A container is more like having **an isolated environment running on the same operating system**.

This is why containers are very useful for microservices, CI/CD pipelines, development environments, and cloud deployments.

---

# 3. Docker Architecture

Docker follows a client-server architecture.

The main components are:

### Docker Client

The Docker CLI is what I use to interact with Docker.

For example:

```bash
docker ps
docker run
docker stop
docker start
```

The client sends these requests to the Docker daemon.

### Docker Daemon

The Docker daemon runs in the background and is responsible for managing:

* Images
* Containers
* Networks
* Volumes

### Docker Image

An image is a **read-only template** used to create containers.

Examples:

```text
ubuntu
nginx
hello-world
```

### Docker Container

A container is a **running instance of an image**.

For example:

```text
ubuntu image → ubuntu container
nginx image → nginx container
```

### Docker Registry

A registry stores Docker images.

**Docker Hub** is a popular public registry from which images can be downloaded.

### Simple flow

```text
Docker CLI
    ↓
Docker Daemon
    ↓
Docker Image
    ↓
Docker Container
    ↓
Application
```

When an image is not available locally, Docker can pull it from a registry such as Docker Hub.

---

# 4. Docker Installation

I verified that Docker was installed and working on my machine.

I also worked with Docker containers directly from the terminal instead of only learning the commands theoretically.

---

# 5. Working with an Ubuntu Container

I worked with an Ubuntu container using the `ubuntu:latest` image.

The container was named:

```text
new-img
```

Its container ID was:

```text
24b3ac55f178
```

I verified the running container using:

```bash
docker ps
```

The output showed:

```text
CONTAINER ID   IMAGE           COMMAND       STATUS       NAMES
24b3ac55f178   ubuntu:latest   "/bin/bash"   Up ...       new-img
```

This helped me understand that Docker containers have their own:

* Container ID
* Image
* Command
* Status
* Name

---

# 6. Listing Running Containers

The command:

```bash
docker ps
```

shows only currently running containers.

For example, I had the following containers running:

```text
ubuntu:latest
ghcr.io/open-webui/open-webui:main
```

The Open WebUI container was also exposing a port:

```text
0.0.0.0:3000 -> 8080/tcp
```

This is an example of Docker's port mapping, where a port on the host machine is connected to a port inside the container.

---

# 7. Stopping a Container

I stopped my Ubuntu container using its container ID:

```bash
docker stop 24b3ac55f178
```

Docker returned:

```text
24b3ac55f178
```

After that, I ran:

```bash
docker ps
```

The Ubuntu container was no longer shown because it was stopped.

This helped me understand the difference between a **running container** and a **stopped container**.

---

# 8. Starting a Stopped Container

Instead of creating a new container, I started the same container again:

```bash
docker start 24b3ac55f178
```

Docker returned:

```text
24b3ac55f178
```

Running:

```bash
docker ps
```

again showed the Ubuntu container as running.

This is an important difference:

```text
docker stop  → stops an existing container
docker start → starts that same container again
```

---

# 9. Viewing Container Logs

I also explored Docker logs.

Running:

```bash
docker logs
```

without specifying a container produced an error because Docker needs to know which container's logs should be displayed.

The correct command is:

```bash
docker logs 24b3ac55f178
```

or:

```bash
docker logs new-img
```

I also tried:

```bash
docker logs -f new-img
```

The `-f` option means **follow the logs**, so Docker continues displaying new log output.

I stopped following the logs using:

```text
Ctrl + C
```

---

# 10. Important Docker Commands

| Command          | Purpose                                  |
| ---------------- | ---------------------------------------- |
| `docker ps`      | Show running containers                  |
| `docker ps -a`   | Show all containers                      |
| `docker images`  | Show locally available images            |
| `docker run`     | Create and start a container             |
| `docker stop`    | Stop a running container                 |
| `docker start`   | Start a stopped container                |
| `docker rm`      | Remove a container                       |
| `docker logs`    | View container logs                      |
| `docker exec`    | Run a command inside a running container |
| `docker pull`    | Download an image                        |
| `docker inspect` | View detailed container information      |

---

# 11. Detached Mode

A container can be started in the background using the `-d` option.

Example:

```bash
docker run -d nginx
```

Here:

```text
-d = detached mode
```

The terminal is returned immediately while the container continues running in the background.

This is useful for services such as web servers that should continue running without keeping the terminal attached to them.

---

# 12. Naming Containers

Docker automatically generates a name for a container if one is not provided.

A custom name can be assigned using:

```bash
docker run --name my-container ubuntu
```

In my practice, my Ubuntu container had the custom name:

```text
new-img
```

This makes commands easier because I can use:

```bash
docker logs new-img
```

instead of remembering the full container ID.

---

# 13. Port Mapping

Containers have their own networking environment.

To make a service inside a container accessible through the host machine, Docker can map ports using:

```text
-p host_port:container_port
```

For example:

```bash
docker run -d -p 8080:80 nginx
```

This means:

```text
Host port 8080 → Container port 80
```

So the Nginx service running inside the container can be accessed through port `8080` on the host.

---

# 14. Interactive Containers

The `-it` options are commonly used when we want to interact directly with a container.

```bash
docker run -it ubuntu /bin/bash
```

Here:

```text
-i = interactive
-t = allocate a terminal
```

This allows us to enter the container and work with it through a shell.

A container can therefore feel similar to working with a small Linux environment, although it is still a container and not a full virtual machine.

---

# 15. Running Commands Inside a Container

Docker also provides `docker exec` to run commands inside an already running container.

Example:

```bash
docker exec -it new-img /bin/bash
```

This is useful when we need to troubleshoot or inspect a running container.

For example:

```bash
docker exec new-img ls
```

can execute `ls` inside the container.

---

# 16. What I Understood Today

Before working with Docker, containers were mostly a concept to me.

After actually running and managing a container, I understood the basic Docker workflow much better:

```text
Docker Image
      ↓
docker run
      ↓
Container
      ↓
docker ps
      ↓
docker logs / docker exec
      ↓
docker stop
      ↓
docker start
      ↓
docker rm
```

The biggest thing I understood today is that an **image is the template**, while a **container is the running instance created from that image**.

I also learned that stopping a container does not remove it. A stopped container can be started again, while `docker rm` is used when the container itself needs to be removed.

---

## Key Takeaways

* Docker is used to build and run applications in containers.
* Containers are lighter than virtual machines because they share the host OS kernel.
* Docker images are templates used to create containers.
* Containers are running instances of images.
* Docker Hub can be used as a registry for container images.
* `docker ps` shows running containers.
* `docker ps -a` shows running and stopped containers.
* `docker stop` stops a container without removing it.
* `docker start` starts an existing stopped container.
* `docker logs` helps troubleshoot containers.
* `docker exec` allows commands to be run inside running containers.
* `-d` runs containers in detached mode.
* `-it` provides an interactive terminal.
* `-p` is used for port mapping.
* `--name` gives a container a custom name.

---

## Conclusion

Day 29 was my first hands-on introduction to Docker.

Instead of only learning what containers are, I actually created and managed a container, checked its status, stopped it, started it again, and explored its logs.

This gives me the foundation needed for the next Docker topics such as **Dockerfiles, building images, volumes, networking, and eventually Docker Compose**.

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
