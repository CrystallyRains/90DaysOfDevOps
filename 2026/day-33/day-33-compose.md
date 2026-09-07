# Day 33 – Docker Compose: Multi-Container Basics

## Task

The goal of Day 33 was to use **Docker Compose to run and manage multi-container applications with a single command**.

Instead of manually creating networks, volumes, and containers one by one, Docker Compose lets us define the application in a `docker-compose.yml` file.

---

# Task 1 – Install & Verify Docker Compose

First, I verified that Docker Compose was available.

```bash
docker compose version
```

Docker Compose is available as the `docker compose` subcommand of the Docker CLI.

---

# Task 2 – First Compose File

## 1. Create the project directory

```bash
mkdir compose-basics
cd compose-basics
```

## 2. Create `docker-compose.yml`

The first Compose file contained a single Nginx service:

```yaml
services:
  web:
    image: nginx:latest
    ports:
      - "80:80"
    networks:
      - webnet

networks:
  webnet:
```

### What this does

- `services` defines the containers in the application.
- `web` is the service name.
- `image` specifies the Docker image to use.
- `ports` maps host port `80` to container port `80`.
- `networks` attaches the service to a Docker network.

## 3. Start the service

```bash
docker compose up -d
```

The `-d` flag starts the service in detached mode.

## 4. Verify the running container

```bash
docker compose ps
```

The Nginx container was running and port `80` was exposed.

## 5. Test Nginx

I created an `html/index.html` file and verified that Nginx could serve it.

A request to `/` returned:

```text
HTTP 200
```

This confirmed that the container was running correctly and serving the application.

## 6. Stop and remove the Compose application

```bash
docker compose down
```

This removed the Compose-created container and network.

---

# Task 3 – WordPress + MySQL

The second part was to run a WordPress application with a MySQL database.

The important requirements were:

- WordPress and MySQL should communicate with each other.
- MySQL data should persist using a named volume.
- WordPress should connect to MySQL using the **service name**.

## Compose File

```yaml
services:
  web:
    image: wordpress:latest
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: "${WORDPRESS_DB_USER}"
      WORDPRESS_DB_PASSWORD: "${MYSQL_ROOT_PASSWORD}"
      WORDPRESS_DB_NAME: "${WORDPRESS_DB_NAME}"
    networks:
      - webnet

  db:
    image: mysql:5.7
    platform: linux/amd64
    environment:
      MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT_PASSWORD}"
      MYSQL_DATABASE: "${WORDPRESS_DB_NAME}"
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - webnet

volumes:
  db_data:

networks:
  webnet:
```

## Why `db:3306`?

The MySQL service is named:

```yaml
db:
```

Docker Compose provides service-name based DNS between containers on the same network.

Therefore, WordPress does **not** connect to:

```text
localhost
```

Instead, it connects to:

```text
db:3306
```

Here:

- `db` = MySQL service name
- `3306` = MySQL container port

This is one of the important concepts from this task:

> **In a Compose application, services can communicate using their service names.**

---

# MySQL on Apple Silicon

While starting the WordPress + MySQL setup, I encountered:

```text
no matching manifest for linux/arm64/v8
```

The issue was with:

```yaml
image: mysql:5.7
```

My machine uses an ARM64 architecture, while the requested MySQL 5.7 image did not provide a matching ARM64 image manifest.

For this exercise, I used:

```yaml
platform: linux/amd64
```

This tells Docker Desktop to run the AMD64 image through emulation.

So the database service became:

```yaml
db:
  image: mysql:5.7
  platform: linux/amd64
```

This was useful for completing the exercise, although using an image with native architecture support would generally be preferable when possible.

---

# Environment Variables

## Using variables directly in Compose

Environment variables can be defined directly inside a service:

```yaml
environment:
  MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT_PASSWORD}"
```

## Using a `.env` file

I created a `.env` file:

```env
WORDPRESS_DB_USER=root
MYSQL_ROOT_PASSWORD=root
WORDPRESS_DB_NAME=wordpress
```

Docker Compose automatically reads variables from `.env` and substitutes them into the Compose file.

For example:

```yaml
MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT_PASSWORD}"
```

gets its value from:

```env
MYSQL_ROOT_PASSWORD=root
```

### Important

The `.env` file can contain secrets, so it should not be committed to a public Git repository.

A common practice is to add it to `.gitignore`.

---

# Task 4 – Compose Commands

## Start services in detached mode

```bash
docker compose up -d
```

Starts the services in the background.

## View running services

```bash
docker compose ps
```

Shows the containers managed by the current Compose project.

## View logs of all services

```bash
docker compose logs
```

For continuously following logs:

```bash
docker compose logs -f
```

## View logs of a specific service

```bash
docker compose logs web
```

or:

```bash
docker compose logs db
```

To follow the logs:

```bash
docker compose logs -f db
```

## Stop services without removing them

```bash
docker compose stop
```

This stops the containers but does not remove them.

## Remove the Compose application

```bash
docker compose down
```

This removes the containers and Compose-created network.

The named database volume remains unless volumes are explicitly removed.

## Rebuild images

When a service uses a Dockerfile and the Dockerfile changes:

```bash
docker compose build
```

or:

```bash
docker compose up -d --build
```

The second command rebuilds the required images and starts the services.

---

# Task 5 – Volumes & Persistence

MySQL uses a named volume:

```yaml
volumes:
  - db_data:/var/lib/mysql
```

The volume is declared at the bottom:

```yaml
volumes:
  db_data:
```

This separates the database data from the lifecycle of the MySQL container.

The important distinction is:

```text
Container
   ↓
can be removed/recreated

Named Volume
   ↓
stores persistent database data
```

Therefore:

```bash
docker compose down
```

does not normally delete the `db_data` volume.

If the application is started again:

```bash
docker compose up -d
```

MySQL can reuse the existing database data.

### Important warning

Do not use:

```bash
docker compose down -v
```

unless the intention is to remove the volumes as well.

Removing the database volume means removing the persisted MySQL data.

---

# Compose Networking

Docker Compose creates a network for the application automatically.

Services attached to the same Compose network can communicate with each other using their service names.

For this application:

```text
WordPress
    |
    | db:3306
    ↓
  MySQL
```

The user does not need to find the MySQL container's IP address.

This is much easier and more reliable than manually configuring container IP addresses.

---

# Key Concepts Learned

### 1. Compose manages multiple containers

Instead of running containers individually:

```bash
docker run ...
docker network create ...
docker run ...
```

we can define the application in one YAML file and use:

```bash
docker compose up -d
```

### 2. Service names provide container-to-container discovery

WordPress uses:

```text
db:3306
```

instead of:

```text
localhost:3306
```

because `db` is the MySQL service name.

### 3. Named volumes provide persistence

```yaml
db_data:/var/lib/mysql
```

keeps MySQL data outside the container's writable layer.

### 4. `.env` keeps configuration separate

Compose can load values from `.env` and substitute them into the YAML file.

### 5. `docker compose down` and volume removal are different

```bash
docker compose down
```

removes containers and networks.

```bash
docker compose down -v
```

also removes named volumes.

That difference matters when working with databases.

---

# Useful Compose Command Cheat Sheet

| Command | Purpose |
|---|---|
| `docker compose up` | Start services |
| `docker compose up -d` | Start services in detached mode |
| `docker compose up -d --build` | Rebuild and start |
| `docker compose ps` | Show Compose services |
| `docker compose logs` | View all logs |
| `docker compose logs -f` | Follow all logs |
| `docker compose logs web` | View one service's logs |
| `docker compose stop` | Stop services |
| `docker compose start` | Start stopped services |
| `docker compose down` | Remove containers and networks |
| `docker compose build` | Build images |
| `docker compose config` | Validate/render the Compose configuration |

---

# What I Learned

Before Compose, running a multi-container application meant managing containers, networks, and volumes separately.

With Docker Compose, the application architecture can be described declaratively in one YAML file.

The biggest concept from this task was not just learning Compose commands.

It was understanding the relationship between:

```text
Services
   ↓
Networking
   ↓
Service-name DNS
   ↓
Volumes
   ↓
Environment variables
```

Together, these allow multiple containers to behave like one application stack while keeping each component isolated.

---

# Submission

Files added under:

```text
2026/day-33/
```

Expected files:

```text
day-33-compose.md
compose-basics/docker-compose.yml
WordPress/MySQL docker-compose.yml
```

The `.env` file containing local secrets should not be committed to the repository.

---

# Learnings

Docker Compose made the jump from running individual containers to managing an application stack much clearer.

The important shift was:

> **Instead of thinking about individual containers, start thinking about the application as a set of connected services.**
