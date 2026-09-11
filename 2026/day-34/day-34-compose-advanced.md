# Day 34: Docker Compose: Real-World Multi-Container Apps

## Objective

The goal of Day 34 was to move beyond basic Docker Compose usage and work with a more realistic multi-container setup.

The challenge covered:

- Multiple services working together
- Custom Dockerfiles with `build:`
- Database healthchecks
- `depends_on` with `condition: service_healthy`
- Restart policies
- Named volumes
- Explicit networks
- Service labels
- Scaling services with `--scale`

For this exercise, I used my existing SocialPulse Social Network application instead of creating a separate Hello World application.

The existing project already contains a frontend, Node.js backend, MySQL database, and Nginx reverse proxy. I added Redis as a Compose cache service so the project could also demonstrate the cache part of the Day 34 challenge.

The application code was not modified to use Redis. Redis was added as an infrastructure service for this Compose exercise.

## Project Structure

```text
SocialPulse-Social-Network-App-Open-Source/
├── API/
├── frontend/
├── nginx/
├── 2026/
├── docker-compose.yml
├── docker-compose-day34.yml
├── mydevify_social.sql
└── README.md
```

The Day 34 Compose file is:

```text
docker-compose-day34.yml
```

The existing application Dockerfiles are reused through the `build:` configuration.

# Architecture

The existing application architecture already had multiple services:

```text
                    Nginx
                      |
             +--------+--------+
             |                 |
         Frontend           Backend
                               |
                             MySQL
```

For Day 34, Redis was added:

```text
                         Nginx
                           |
              +------------+------------+
              |                         |
          Frontend                   Backend
                                        |
                              +---------+---------+
                              |                   |
                            MySQL               Redis
```

All services are connected through the explicit Docker network:

```text
socialpulse-net
```

The database uses a named volume for persistent MySQL data, while the uploads directory is also stored in a named volume shared by the backend and Nginx.

# Task 1: Build Your Own App Stack

## Requirement

The challenge asks for:

- A web application
- A database
- Redis cache

A simple application is enough, but it should be containerized with a Dockerfile.

## Implementation

Instead of creating another application, I used the existing SocialPulse application.

The core Day 34 services are:

```text
backend
database
cache
```

The project also keeps:

```text
frontend
nginx
```

because they are already part of the working application.

The backend is built from the existing Dockerfile:

```yaml
backend:
  build:
    context: ./API
```

The MySQL database uses:

```yaml
database:
  image: mysql:8.4
```

Redis uses:

```yaml
cache:
  image: redis:7-alpine
```

This gives the project the required application, database, and cache components while preserving the existing application architecture.

# Day 34 Compose File

```yaml
services:

  frontend:
    build:
      context: ./frontend
    expose:
      - "4173"
    networks:
      - socialpulse-net
    labels:
      project: socialpulse
      component: frontend

  backend:
    build:
      context: ./API
    expose:
      - "8800"
    environment:
      MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT_PASSWORD}"
    volumes:
      - uploads:/app/uploads
    networks:
      - socialpulse-net
    depends_on:
      database:
        condition: service_healthy
      cache:
        condition: service_healthy
    labels:
      project: socialpulse
      component: backend

  database:
    image: mysql:8.4
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT_PASSWORD}"
      MYSQL_DATABASE: "${MYSQL_DATABASE}"
    volumes:
      - mysql:/var/lib/mysql
      - ./mydevify_social.sql:/docker-entrypoint-initdb.d/mydevify_social.sql
    networks:
      - socialpulse-net
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-uroot", "-p${MYSQL_ROOT_PASSWORD}"]
      interval: 5s
      timeout: 5s
      retries: 10
    labels:
      project: socialpulse
      component: database

  cache:
    image: redis:7-alpine
    restart: always
    networks:
      - socialpulse-net
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
    labels:
      project: socialpulse
      component: cache

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    networks:
      - socialpulse-net
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
      - uploads:/usr/share/nginx/html/uploads:ro
    depends_on:
      - frontend
      - backend
    labels:
      project: socialpulse
      component: reverse-proxy

volumes:
  mysql:
  uploads:

networks:
  socialpulse-net:
```

# Compose File: Line-by-Line Explanation

## `services:`

```yaml
services:
```

This starts the service definitions. Each service represents a container that Docker Compose manages.

This setup contains five services:

```text
frontend
backend
database
cache
nginx
```

## Frontend

```yaml
frontend:
```

Defines the frontend container.

```yaml
build:
  context: ./frontend
```

`build:` tells Docker Compose to build an image instead of simply pulling a pre-built image. `context: ./frontend` means Docker uses the `frontend` directory as the build context and looks for the Dockerfile there.

```yaml
expose:
  - "4173"
```

Makes port 4173 available to other containers on the Docker network without publishing it directly to the host.

```yaml
networks:
  - socialpulse-net
```

Connects the frontend to the custom Docker network.

```yaml
labels:
  project: socialpulse
  component: frontend
```

Adds metadata to identify the project and service component.

## Backend

```yaml
backend:
```

Defines the Node.js backend service.

```yaml
build:
  context: ./API
```

Builds the backend image using the Dockerfile located in the `API` directory.

```yaml
expose:
  - "8800"
```

Makes the backend port available to other services on the Docker network without publishing it directly on the EC2 host.

```yaml
environment:
  MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT_PASSWORD}"
```

Passes the MySQL root password into the backend container. The value is resolved from the environment used by Compose.

```yaml
volumes:
  - uploads:/app/uploads
```

Mounts the named `uploads` volume into `/app/uploads`, allowing uploaded files to persist outside the backend container.

```yaml
networks:
  - socialpulse-net
```

Connects the backend to the custom network.

Because the backend and database are on the same Docker network, the backend can communicate with the database using the service name, for example:

```text
database:3306
```

```yaml
depends_on:
  database:
    condition: service_healthy
  cache:
    condition: service_healthy
```

The backend depends on both MySQL and Redis. It waits for the healthchecks of both services to report `healthy` before starting.

This is different from simply using:

```yaml
depends_on:
  - database
```

because the healthcheck condition verifies service readiness.

```yaml
labels:
  project: socialpulse
  component: backend
```

Adds labels identifying this container as part of the SocialPulse project and as the backend component.

## Database

```yaml
database:
```

Defines the MySQL database container.

```yaml
image: mysql:8.4
```

Uses the official MySQL 8.4 image.

```yaml
restart: always
```

Enables the `always` restart policy. If the database container stops, Docker attempts to restart it.

```yaml
environment:
  MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT_PASSWORD}"
  MYSQL_DATABASE: "${MYSQL_DATABASE}"
```

Configures the MySQL root password and database name.

```yaml
volumes:
  - mysql:/var/lib/mysql
```

Mounts the named `mysql` volume to MySQL's data directory so database data can persist outside the container filesystem.

```yaml
- ./mydevify_social.sql:/docker-entrypoint-initdb.d/mydevify_social.sql
```

Mounts the project's SQL file into the MySQL initialization directory. The official MySQL image can execute SQL files placed there when the database is initialized.

```yaml
networks:
  - socialpulse-net
```

Connects MySQL to the custom network. The backend can reach it using the service name `database`.

## MySQL Healthcheck

```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-uroot", "-p${MYSQL_ROOT_PASSWORD}"]
  interval: 5s
  timeout: 5s
  retries: 10
```

The healthcheck tells Docker how to determine whether MySQL is actually ready.

### `test`

```yaml
test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-uroot", "-p${MYSQL_ROOT_PASSWORD}"]
```

Docker executes `mysqladmin ping` inside the database container. If MySQL responds successfully, the healthcheck succeeds.

A running container does not necessarily mean that the database application inside it is ready.

### `interval`

```yaml
interval: 5s
```

Docker checks the database every five seconds.

### `timeout`

```yaml
timeout: 5s
```

Each healthcheck gets up to five seconds to complete.

### `retries`

```yaml
retries: 10
```

Docker allows up to ten unsuccessful checks before considering the service unhealthy.

## Cache

```yaml
cache:
```

Defines the Redis service.

```yaml
image: redis:7-alpine
```

Uses Redis 7 with the Alpine Linux base image.

```yaml
restart: always
```

Automatically restarts the Redis container if it stops.

```yaml
networks:
  - socialpulse-net
```

Connects Redis to the same Docker network.

Redis can be addressed by its Compose service name:

```text
cache:6379
```

if an application needs to connect to it.

```yaml
healthcheck:
  test: ["CMD", "redis-cli", "ping"]
  interval: 5s
  timeout: 3s
  retries: 5
```

The healthcheck runs `redis-cli ping`. A successful response indicates that Redis is ready.

Redis was added for the Compose challenge. The existing SocialPulse backend was not changed to use Redis.

## Nginx

```yaml
nginx:
```

Defines the Nginx reverse proxy.

```yaml
image: nginx:alpine
```

Uses the official Nginx Alpine image.

```yaml
ports:
  - "80:80"
```

Maps port 80 on the EC2 host to port 80 inside the Nginx container.

```yaml
networks:
  - socialpulse-net
```

Connects Nginx to the same network as the frontend and backend.

```yaml
volumes:
  - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
```

Mounts the project's Nginx configuration into the container. The `ro` flag makes the mount read-only.

```yaml
- uploads:/usr/share/nginx/html/uploads:ro
```

Mounts the same named `uploads` volume used by the backend. Nginx can therefore read and serve uploaded files.

```yaml
depends_on:
  - frontend
  - backend
```

Defines a startup dependency on the frontend and backend. This uses the basic dependency form and does not include healthcheck conditions.

```yaml
labels:
  project: socialpulse
  component: reverse-proxy
```

Adds metadata identifying the service as the reverse proxy.

## Named Volumes

```yaml
volumes:
  mysql:
  uploads:
```

Defines named Docker volumes.

The `mysql` volume stores database data.

The `uploads` volume stores application uploads.

Named volumes can survive container recreation, so data does not have to be tied to a particular container.

## Explicit Network

```yaml
networks:
  socialpulse-net:
```

Creates a custom Docker network.

Instead of relying only on Compose's automatically generated default network, the project explicitly defines its own network.

All five services join this network.

Docker's internal DNS allows services to communicate using their Compose service names.

# Task 2: `depends_on` and Healthchecks

The requirement was to make the application wait for the database to become ready.

The database healthcheck is:

```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-uroot", "-p${MYSQL_ROOT_PASSWORD}"]
  interval: 5s
  timeout: 5s
  retries: 10
```

The backend dependency is:

```yaml
depends_on:
  database:
    condition: service_healthy
```

Therefore, Compose waits for the database healthcheck to report `healthy` before starting the backend.

The same approach is used for Redis:

```yaml
depends_on:
  cache:
    condition: service_healthy
```

## Why This Matters

Without a healthcheck, Compose can know that:

```text
MySQL container started
```

but that does not necessarily mean:

```text
MySQL is ready to accept connections
```

With a healthcheck:

```text
Container started
        |
        v
Healthcheck runs
        |
        v
MySQL responds successfully
        |
        v
Service becomes healthy
        |
        v
Backend is allowed to start
```

## Testing

```bash
docker-compose -f docker-compose-day34.yml down
docker-compose -f docker-compose-day34.yml up -d
docker-compose -f docker-compose-day34.yml ps
```

Check MySQL health:

```bash
docker inspect --format='{{.State.Health.Status}}' $(docker-compose -f docker-compose-day34.yml ps -q database)
```

Expected result after successful startup:

```text
healthy
```

Check Redis health:

```bash
docker inspect --format='{{.State.Health.Status}}' $(docker-compose -f docker-compose-day34.yml ps -q cache)
```

# Task 3: Restart Policies

The database uses:

```yaml
restart: always
```

## Testing `restart: always`

The database container can be manually killed:

```bash
docker kill $(docker-compose -f docker-compose-day34.yml ps -q database)
```

Then check:

```bash
docker-compose -f docker-compose-day34.yml ps
```

The database should be restarted automatically.

The restart count can be checked with:

```bash
docker inspect --format='{{.RestartCount}}' $(docker-compose -f docker-compose-day34.yml ps -q database)
```

## `always`

```yaml
restart: always
```

Restarts the container whenever it stops.

This can be useful for critical services where automatic recovery is desirable.

## `on-failure`

```yaml
restart: on-failure
```

Restarts the container when its main process exits with a failure status.

This is useful when a service should recover from application crashes but should not necessarily restart after every type of stop.

## Other Policies

### `no`

```yaml
restart: "no"
```

No automatic restart.

### `unless-stopped`

```yaml
restart: unless-stopped
```

Restarts the container automatically unless it has been explicitly stopped.

## Comparison

| Policy | Behaviour |
|---|---|
| `no` | Does not automatically restart |
| `always` | Restarts whenever the container stops |
| `on-failure` | Restarts when the process exits with a failure |
| `unless-stopped` | Restarts unless explicitly stopped |

# Task 4: Custom Dockerfiles in Compose

The challenge requires using `build:` instead of relying only on a pre-built application image.

The frontend uses:

```yaml
frontend:
  build:
    context: ./frontend
```

The backend uses:

```yaml
backend:
  build:
    context: ./API
```

Compose therefore builds the application images from the existing project Dockerfiles.

# Frontend Dockerfile

The frontend Dockerfile uses a multi-stage build.

The relevant structure is:

```dockerfile
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

FROM node:20-alpine AS worker

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/vite.config.js ./vite.config.js
```

## Line-by-Line Explanation

```dockerfile
FROM node:20-alpine AS builder
```

Creates the builder stage using Node.js 20 Alpine. `AS builder` gives the stage a name so files can later be copied from it.

```dockerfile
WORKDIR /app
```

Sets `/app` as the working directory.

```dockerfile
COPY package*.json ./
```

Copies the package files into the image.

Keeping these files separate from the source-code copy allows Docker to reuse the dependency layer when package files have not changed.

```dockerfile
RUN npm install
```

Installs the frontend dependencies.

```dockerfile
COPY . .
```

Copies the remaining frontend source code into the builder image.

```dockerfile
RUN npm run build
```

Runs the frontend build command. For the Vite application, this generates the build output in:

```text
/app/dist
```

The second stage starts with:

```dockerfile
FROM node:20-alpine AS worker
```

This creates a new image stage.

```dockerfile
WORKDIR /app
```

Sets `/app` as the working directory.

```dockerfile
COPY --from=builder /app/node_modules ./node_modules
```

Copies the installed dependencies from the builder stage.

```dockerfile
COPY --from=builder /app/dist ./dist
```

Copies the generated frontend build.

```dockerfile
COPY --from=builder /app/vite.config.js ./vite.config.js
```

Copies the Vite configuration required by the application.

# Backend Dockerfile

The backend Dockerfile follows a simpler structure:

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN mkdir -p /app/uploads/posts

CMD ["node", "src/index.js"]
```

## Line-by-Line Explanation

```dockerfile
FROM node:20-alpine
```

Uses Node.js 20 on Alpine Linux as the base image.

```dockerfile
WORKDIR /app
```

Sets `/app` as the working directory.

```dockerfile
COPY package*.json ./
```

Copies the package files first.

```dockerfile
RUN npm install
```

Installs the backend dependencies.

```dockerfile
COPY . .
```

Copies the backend application source code.

```dockerfile
RUN mkdir -p /app/uploads/posts
```

Creates the directory required for uploaded post files.

```dockerfile
CMD ["node", "src/index.js"]
```

Starts the Node.js backend by running `src/index.js`.

# Code Change and Rebuild

The challenge requires making a code change and rebuilding the application.

After making a small source-code change, the backend can be rebuilt and restarted with one command:

```bash
docker-compose -f docker-compose-day34.yml up -d --build backend
```

The complete stack can be rebuilt with:

```bash
docker-compose -f docker-compose-day34.yml up -d --build
```

This demonstrates the Compose workflow:

```text
Code Change
    |
    v
docker-compose up -d --build
    |
    v
Dockerfile Build
    |
    v
New Image
    |
    v
Container Recreated
```

# Build Troubleshooting

During the Day 34 build, the application build stages completed successfully, including:

```text
npm install
npm run build
```

The backend image was also successfully exported.

However, the final frontend image export failed because the EC2 instance ran out of disk space.

The error was:

```text
no space left on device
```

The failure occurred while Docker was exporting the frontend image.

This means the application build itself progressed successfully, but the complete image export could not finish because the Docker host did not have enough storage.

This is a real-world Docker troubleshooting issue and should be documented rather than claiming that the complete deployment succeeded.

The Dockerfile warning:

```text
FromAsCasing: 'as' and 'FROM' keywords' casing do not match
```

was only a style warning.

It was not the cause of the build failure.

The actual failure was:

```text
no space left on device
```

# Task 5: Named Networks, Volumes and Labels

## Named Network

The Compose file defines:

```yaml
networks:
  socialpulse-net:
```

Every service connects to this network:

```yaml
networks:
  - socialpulse-net
```

This gives the project an explicit network instead of relying only on the default network.

## Named Volumes

The project defines:

```yaml
volumes:
  mysql:
  uploads:
```

The MySQL data directory uses:

```yaml
- mysql:/var/lib/mysql
```

The backend uploads directory uses:

```yaml
- uploads:/app/uploads
```

Nginx also mounts:

```yaml
- uploads:/usr/share/nginx/html/uploads:ro
```

This allows the backend to write uploads while Nginx can read and serve them.

## Labels

Labels were added to the services.

Example:

```yaml
labels:
  project: socialpulse
  component: backend
```

Other components include:

```text
frontend
database
cache
reverse-proxy
```

Labels provide metadata that can help identify and organize containers.

They can be inspected with:

```bash
docker inspect $(docker-compose -f docker-compose-day34.yml ps -q backend) --format='{{json .Config.Labels}}'
```

# Task 6: Scaling

The bonus task asks us to scale the web application to three replicas.

The command is:

```bash
docker-compose -f docker-compose-day34.yml up -d --scale backend=3
```

Then:

```bash
docker-compose -f docker-compose-day34.yml ps
```

can be used to view the replicas.

## Why Port Mapping Causes a Problem

If a service contains:

```yaml
ports:
  - "8800:8800"
```

and we try:

```bash
docker-compose -f docker-compose-day34.yml up -d --scale backend=3
```

Compose would need to bind host port 8800 for all three containers.

The same host port cannot be bound independently by all three containers. This creates a port conflict.

```text
Host
Port 8800
   |
   +----> Backend 1
   |
   +----> Backend 2   X conflict
   |
   +----> Backend 3   X conflict
```

In this Day 34 setup, the backend uses:

```yaml
expose:
  - "8800"
```

instead of:

```yaml
ports:
  - "8800:8800"
```

Therefore, the backend port is not directly bound to the host.

This avoids the specific host-port collision caused by scaling.

## `expose` vs `ports`

### `ports`

```yaml
ports:
  - "8800:8800"
```

Publishes the container port to the host.

### `expose`

```yaml
expose:
  - "8800"
```

Makes the port available to other containers on the Docker network without publishing it directly on the host.

This is useful for internal services that sit behind a reverse proxy or load balancer.

# Useful Compose Commands

This EC2 environment uses the standalone `docker-compose` command, so the commands for this project use:

```bash
docker-compose -f docker-compose-day34.yml
```

## Validate the Compose File

```bash
docker-compose -f docker-compose-day34.yml config
```

## List Services

```bash
docker-compose -f docker-compose-day34.yml config --services
```

Expected services:

```text
cache
database
frontend
backend
nginx
```

## Build and Start

```bash
docker-compose -f docker-compose-day34.yml up -d --build
```

## Check Containers

```bash
docker-compose -f docker-compose-day34.yml ps
```

## Stop and Remove Containers

```bash
docker-compose -f docker-compose-day34.yml down
```

## Check Database Health

```bash
docker inspect --format='{{.State.Health.Status}}' $(docker-compose -f docker-compose-day34.yml ps -q database)
```

## Check Redis Health

```bash
docker inspect --format='{{.State.Health.Status}}' $(docker-compose -f docker-compose-day34.yml ps -q cache)
```

## Check Restart Count

```bash
docker inspect --format='{{.RestartCount}}' $(docker-compose -f docker-compose-day34.yml ps -q database)
```

## Inspect Volumes

```bash
docker volume ls
```

## Inspect Network

```bash
docker network ls
```

## Inspect Labels

```bash
docker inspect $(docker-compose -f docker-compose-day34.yml ps -q backend) --format='{{json .Config.Labels}}'
```

## Scale Backend

```bash
docker-compose -f docker-compose-day34.yml up -d --scale backend=3
```

## Scale Back Down

```bash
docker-compose -f docker-compose-day34.yml up -d --scale backend=1
```

# Key Learnings

## 1. Container Running Does Not Always Mean Application Ready

A database container can be running while the database process is still initializing.

Healthchecks allow Docker to distinguish between:

```text
running
```

and:

```text
healthy
```

## 2. `depends_on` Can Control Service Readiness

Using:

```yaml
condition: service_healthy
```

allows another service to wait for a dependency's healthcheck before starting.

## 3. Restart Policies Improve Resilience

Different policies provide different recovery behaviours:

```text
no
always
on-failure
unless-stopped
```

The correct policy depends on the service and the desired recovery behaviour.

## 4. Named Volumes Persist Data

Container lifecycle and data lifecycle do not have to be the same.

The MySQL data is stored in:

```text
mysql
```

rather than only inside the database container's writable layer.

## 5. Custom Networks Provide Controlled Service Communication

The services communicate through:

```text
socialpulse-net
```

Docker's internal DNS allows service names to be used instead of hard-coded container IP addresses.

## 6. `build:` Connects Compose with Dockerfiles

Compose can build application images directly from project Dockerfiles:

```text
Source Code
    |
    v
Dockerfile
    |
    v
Docker Image
    |
    v
Docker Compose Service
    |
    v
Container
```

## 7. Scaling Requires Architecture Considerations

Simply creating multiple replicas is not enough.

Host port mappings can create conflicts when multiple containers try to bind the same host port.

Internal services can communicate through the Docker network, while a reverse proxy or load balancer can handle incoming traffic.

# Final Architecture

```text
                         Client
                           |
                           v
                     Host Port 80
                           |
                           v
                        Nginx
                           |
                  +--------+--------+
                  |                 |
                  v                 v
              Frontend          Backend
                                    |
                              +-----+-----+
                              |           |
                              v           v
                           MySQL        Redis
```

All services communicate through:

```text
socialpulse-net
```

Persistent data is handled through:

```text
mysql
uploads
```

Service organization is improved through labels:

```text
project: socialpulse
component: frontend
component: backend
component: database
component: cache
component: reverse-proxy
```

# Final Result

Day 34 focused on taking an existing multi-container application and applying more advanced Docker Compose concepts.

The final Compose configuration demonstrates:

- A web application
- MySQL database
- Redis cache
- Existing frontend and Nginx services
- Custom application Dockerfiles
- `build:` in Compose
- MySQL healthcheck
- Redis healthcheck
- `depends_on`
- `condition: service_healthy`
- Restart policies
- Explicit Docker network
- Named volumes
- Service labels
- Service scaling concepts
- Port mapping considerations
- Real-world Docker troubleshooting

One real-world issue encountered during the build was the Docker host running out of disk space while exporting the frontend image.

The error was:

```text
no space left on device
```

This reinforced another important lesson from working with containers on small EC2 instances: Docker images, build layers, containerd data, volumes, and build cache all consume host storage and must be monitored.

# Day 34 Summary

```text
Docker Compose
      |
      +-- Multiple services
      |
      +-- Custom Dockerfiles
      |
      +-- Healthchecks
      |
      +-- depends_on
      |
      +-- Restart policies
      |
      +-- Named volumes
      |
      +-- Custom networks
      |
      +-- Labels
      |
      +-- Scaling
      |
      +-- Real-world troubleshooting
```

The main takeaway from Day 34 was that Docker Compose is not only about starting multiple containers. It is also about defining how those containers communicate, how they recover, how their data persists, how their readiness is checked, and how the application behaves when the infrastructure changes.
