# Day 31 – Dockerfiles: Building Custom Images

## Task

Today I moved from simply running Docker images to understanding how Docker images are actually built.

I practiced writing Dockerfiles, building custom images, serving a static website with Nginx, using `.dockerignore`, and understanding Docker's build context, image layers, intermediate containers, caching, and build optimization.

---

## Task 1: Your First Dockerfile

Created a custom Ubuntu-based image that installs `curl` and prints a message when the container starts.

### Dockerfile

```dockerfile
FROM ubuntu

RUN apt-get update && apt-get install -y curl

CMD ["echo", "Hello from my custom image!"]
```

### Build

```bash
docker build -t my-ubuntu:v1 .
```

### Run

```bash
docker run my-ubuntu:v1
```

### Output

```text
Hello from my custom image!
```

### What I learned

- `FROM` defines the base image.
- `RUN` executes commands while building the image.
- `CMD` defines the default command that runs when a container starts.
- An image is built first, and containers are created from that image.

---

## Task 2: Dockerfile Instructions

Practiced the main Dockerfile instructions:

| Instruction | Purpose |
|---|---|
| `FROM` | Specifies the base image |
| `RUN` | Executes a command during the image build |
| `COPY` | Copies files from the build context into the image |
| `WORKDIR` | Sets the working directory |
| `EXPOSE` | Documents the port the application uses |
| `CMD` | Specifies the default command when the container starts |

### Important distinction

`RUN` executes something **during image build**.

`CMD` specifies what should normally execute **when a container starts**.

---

## Task 3: CMD vs ENTRYPOINT

### CMD

Example:

```dockerfile
FROM ubuntu

CMD ["echo", "hello"]
```

Running the image normally executes:

```text
echo hello
```

A `CMD` can be overridden when running the container:

```bash
docker run <image> echo "custom command"
```

So I think of `CMD` as:

> The default command for the container.

### ENTRYPOINT

Example:

```dockerfile
FROM ubuntu

ENTRYPOINT ["echo"]
```

Running:

```bash
docker run <image> hello
```

effectively executes:

```text
echo hello
```

The additional argument is passed to the `ENTRYPOINT`.

So I think of `ENTRYPOINT` as:

> The main executable that the container is designed to run.

### CMD vs ENTRYPOINT

```text
CMD
→ Default behavior
→ Can easily be overridden

ENTRYPOINT
→ Main executable
→ Arguments are passed to it
```

They can also be used together:

```dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]
```

This effectively gives:

```text
python app.py
```

while allowing the default argument to be replaced.

---

## Task 4: Build a Simple Web App Image

Created a simple `index.html` and served it using Nginx.

### Dockerfile

```dockerfile
FROM nginx:alpine

COPY index.html /usr/share/nginx/html/

EXPOSE 80
```

Nginx serves its default web content from:

```text
/usr/share/nginx/html/
```

So the HTML file needs to be copied there.

### Build

```bash
docker build -t my-website:v1 .
```

### Run

```bash
docker run -d -p 80:80 my-website:v1
```

The port mapping:

```text
80:80
│  │
│  └── Container port
└───── Host port
```

allows traffic arriving on port `80` of the host to reach port `80` inside the container.

I verified the website by accessing it through the browser.

---

## Task 5: .dockerignore

Created a `.dockerignore` file containing:

```text
node_modules
.git
*.md
.env
```

### What is the Docker Build Context?

When running:

```bash
docker build -t my-image .
```

the `.` tells Docker:

> Use the current directory as the build context.

The build context is the set of files Docker receives and can access during the build.

For example:

```text
my-app/
├── Dockerfile
├── index.html
├── app.py
├── README.md
└── .env
```

The directory specified by `.` becomes the source of files Docker can access during the build.

For example:

```dockerfile
COPY index.html .
```

Docker looks for `index.html` inside the build context.

### What does `.dockerignore` do?

`.dockerignore` works similarly to `.gitignore`, but it is used to control what Docker includes in the **build context**.

For example:

```text
node_modules
.git
*.md
.env
```

These files/directories are excluded from the build context.

They are **not deleted from the host**.

### Why ignore these files?

- `node_modules` — dependencies can be installed inside the image instead of copying the host's dependencies.
- `.git` — Git history is normally not required inside the application image.
- `*.md` — documentation is usually not required by the application.
- `.env` — may contain sensitive information such as passwords, API keys, or connection strings.

For example, dependencies can be installed inside the image:

```dockerfile
COPY package*.json .

RUN npm install
```

Environment variables can be supplied when running the container instead of baking the `.env` file into the image:

```bash
docker run --env-file .env my-image
```

### Important distinction

`.dockerignore` does **not** mean:

> These files are never needed by my application.

It means:

> Do not send these host files as part of the Docker build context.

---

## Task 6: Build Optimization

Practiced Docker's build cache and learned why Dockerfile layer order matters.

Docker builds an image in layers based on the Dockerfile instructions.

For example:

```dockerfile
FROM nginx:alpine

RUN echo "Install dependencies"

EXPOSE 80

COPY index.html /usr/share/nginx/html/
```

Conceptually:

```text
FROM nginx:alpine
        ↓
      Layer
        ↓
RUN ...
        ↓
      Layer
        ↓
EXPOSE 80
        ↓
      Layer
        ↓
COPY index.html
        ↓
      Layer
```

### Docker Build Cache

When an image is built again without changes, Docker can reuse previously created layers.

The build output shows:

```text
Using cache
```

instead of executing the instruction again.

This makes repeated builds faster.

### What happens when something changes?

I changed `index.html` and rebuilt the image.

Docker was able to reuse the earlier unchanged layers, but the layer affected by the changed file had to be rebuilt.

Conceptually:

```text
FROM       → cache
RUN        → cache
EXPOSE     → cache
COPY       → rebuild
```

This demonstrated why the order of Dockerfile instructions matters.

---

# Intermediate Containers

One of the new things I learned today was what this message means during a Docker build:

```text
Removed intermediate container 42e26d421018
```

For a build instruction such as:

```dockerfile
RUN echo "Install dependencies"
```

Docker may temporarily create a container to execute the command.

The process is roughly:

```text
Dockerfile instruction
        ↓
Temporary container
        ↓
Execute command
        ↓
Create/save image layer
        ↓
Remove temporary container
```

For example, during my build I saw:

```text
Running in 42e26d421018

Install dependencies

Removed intermediate container 42e26d421018
```

The container was temporary.

Docker kept the resulting image layer and removed the temporary container because it was no longer needed.

### Important distinction

A temporary intermediate container used during:

```bash
docker build
```

is different from the container I create with:

```bash
docker run
```

`docker build` creates the image.

`docker run` creates a container from that image.

---

# Why Does Layer Order Matter?

Docker caches layers.

If an instruction changes, Docker may need to rebuild that layer and the layers that come after it.

Therefore, a useful optimization principle is:

> Put stable and expensive operations earlier, and frequently changing instructions later.

For example:

```dockerfile
FROM nginx:alpine

RUN echo "Install dependencies"

EXPOSE 80

COPY index.html /usr/share/nginx/html/
```

Here the frequently changing application file is copied near the end.

If `index.html` changes:

```text
FROM
 ↓
RUN
 ↓
EXPOSE
 ↓
COPY ← changes
```

Docker can reuse the earlier layers instead of rebuilding everything from the beginning.

---

# Key Learnings

### Dockerfile

A Dockerfile contains instructions that describe how to build a Docker image.

### Build Context

The `.` in:

```bash
docker build .
```

defines the directory Docker uses as the build context.

### .dockerignore

`.dockerignore` filters files out of the Docker build context.

### Layers

Docker builds images in layers, allowing unchanged layers to be reused.

### Intermediate Containers

Docker may temporarily create containers while executing build instructions. These containers are removed after the resulting image layer is created.

### Build Cache

Docker can reuse unchanged layers instead of rebuilding them.

### Layer Ordering

Stable operations should generally come before frequently changing operations to make better use of Docker's build cache.

---

# Commands Practiced

### Build an image

```bash
docker build -t my-image:v1 .
```

### List images

```bash
docker images
```

### Run a container

```bash
docker run my-image:v1
```

### Run in detached mode with port mapping

```bash
docker run -d -p 80:80 my-website:v1
```

### View running containers

```bash
docker ps
```

### View container logs

```bash
docker logs <container-id>
```

### Remove an image

```bash
docker rmi <image>
```

### Force remove an image

```bash
docker rmi -f <image>
```

---

# Final Takeaway

Today I moved beyond simply running Docker containers and started understanding what happens **during the image-building process**.

The biggest concepts I learned were:

```text
Dockerfile
    ↓
Build Context
    ↓
Build Instructions
    ↓
Image Layers
    ↓
Docker Image
    ↓
Container
```

And for build optimization:

```text
Stable instructions
        ↓
     Cache
        ↓
Frequently changing instructions
        ↓
     Rebuild
```

Docker is not just taking a Dockerfile and producing an image in one step. It builds the image through layers, uses temporary containers while executing build instructions, and reuses cached layers whenever possible.

Understanding this makes Dockerfiles much easier to reason about and optimize.
