# Day 37: Docker Revision

## Goal

Consolidate the Docker concepts covered from Days 29–36 and identify areas that need more practice.

## Self-Assessment

| Topic | Status |
|---|---|
| Run a container from Docker Hub | Can do |
| List, stop, remove containers and images | Can do |
| Explain image layers and caching | Can do |
| Write a Dockerfile from scratch | Can do |
| Explain CMD vs ENTRYPOINT | Shaky |
| Build and tag a custom image | Can do |
| Create and use named volumes | Can do |
| Use bind mounts | Can do |
| Create custom networks and connect containers | Can do |
| Write a Compose file for a multi-container app | Can do |
| Use environment variables and `.env` in Compose | Can do |
| Write a multi-stage Dockerfile | Can do |
| Push an image to Docker Hub | Can do |
| Use healthchecks and `depends_on` | Shaky |

## Quick-Fire Questions

### 1. Image vs Container

An image is a read-only template containing the application, dependencies and filesystem layers.

A container is an instance created from an image.

```text
Image -> Container
```

### 2. What happens to container data when the container is removed?

Data stored only in the container's writable layer is removed.

Persistent data should use a volume or bind mount.

### 3. How do containers on the same custom network communicate?

They communicate using container or Compose service names.

Example:

```env
MYSQL_HOST=mysql
```

Docker's internal DNS resolves `mysql` to the MySQL container.

### 4. `docker compose down` vs `docker compose down -v`

```bash
docker compose down
```

Removes Compose containers and networks.

```bash
docker compose down -v
```

Also removes named volumes created by the Compose project, which can remove persistent database data.

### 5. Why use multi-stage builds?

They separate build dependencies from the runtime image.

Benefits:

- Smaller runtime image
- Fewer unnecessary packages
- Reduced attack surface
- Cleaner production image

Day 36 used:

```text
Builder: python:3.14
Runner:  dhi.io/python:3
```

### 6. `COPY` vs `ADD`

`COPY` copies files and directories into the image.

`ADD` has additional features such as local tar extraction and URL sources.

For normal file copying, prefer `COPY`.

### 7. What does `-p 8080:80` mean?

```text
Host port 8080 -> Container port 80
```

Example:

```bash
docker run -p 8080:80 nginx
```

### 8. How do you check Docker disk usage?

```bash
docker system df
```

For more detail:

```bash
docker system df -v
```

For overall host storage:

```bash
df -h
```

## Dockerfile Revision

```dockerfile
FROM python:3.14

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
```

| Instruction | Purpose |
|---|---|
| `FROM` | Selects the base image |
| `RUN` | Executes commands during the build |
| `COPY` | Copies files into the image |
| `WORKDIR` | Sets the working directory |
| `EXPOSE` | Documents the container port |
| `CMD` | Provides the default command |
| `ENTRYPOINT` | Defines the main executable |

## CMD vs ENTRYPOINT

`CMD` provides the default command or arguments and can be overridden.

```dockerfile
CMD ["python", "app.py"]
```

`ENTRYPOINT` defines the main executable.

```dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]
```

Remember:

```text
ENTRYPOINT = main executable
CMD        = default command/arguments
```

## Volumes

### Named Volume

```bash
docker volume create app-data
docker run -v app-data:/data nginx
```

Docker manages the volume.

### Bind Mount

```bash
docker run -v $(pwd):/app nginx
```

A specific host path is mounted into the container.

```text
Named volume -> managed by Docker
Bind mount   -> specific host path
```

## Custom Network

```bash
docker network create app-network
```

Run containers on it:

```bash
docker run -d --name db --network app-network mysql:8.0
docker run -d --name app --network app-network my-app:latest
```

The app can reach MySQL using:

```text
db
```

instead of the container IP.

## Compose

A basic multi-container structure:

```yaml
services:

  app:
    build: .
    ports:
      - "5000:5000"
    environment:
      DB_HOST: db
    depends_on:
      - db
    networks:
      - app-network

  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
    volumes:
      - db-data:/var/lib/mysql
    networks:
      - app-network

volumes:
  db-data:

networks:
  app-network:
```

Key points:

- `services` defines containers.
- `environment` passes configuration.
- `volumes` provides persistence.
- `networks` controls container communication.
- `depends_on` defines service dependency.
- `healthcheck` verifies actual service health.

## Healthchecks and depends_on

Example:

```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
  interval: 10s
  timeout: 5s
  retries: 5
```

Basic dependency:

```yaml
depends_on:
  - db
```

Health-aware dependency:

```yaml
depends_on:
  db:
    condition: service_healthy
```

Remember:

```text
depends_on       -> dependency/startup relationship
healthcheck      -> service health
service_healthy  -> wait for healthy dependency
```

## Environment Variables

Example `.env`:

```env
MYSQL_USER=admin
MYSQL_PASSWORD=admin
MYSQL_DB=devops
MYSQL_HOST=mysql
```

Use in Compose:

```yaml
environment:
  MYSQL_USER: "${MYSQL_USER}"
  MYSQL_PASSWORD: "${MYSQL_PASSWORD}"
  MYSQL_DB: "${MYSQL_DB}"
  MYSQL_HOST: "${MYSQL_HOST}"
```

Keep `.env` out of the image:

```text
.env
.env.*
```

Add these to `.dockerignore`.

## Day 36 Project Revision

The Day 36 project combined Dockerfile, multi-stage builds, Compose, networking, persistence, environment variables and healthchecks.

```text
                Docker Compose
                      |
          +-----------+-----------+
          |                       |
          v                       v
    Flask Container         MySQL Container
       flask-app                 mysql
          |                       |
          +---- two-tier-ntw -----+
                                  |
                           Persistent Data
```

Dockerfile:

```text
Builder: python:3.14
Runner:  dhi.io/python:3
```

The DHI runtime was verified as:

```text
UID: 65532
GID: 65532
User: nonroot
```

The project used:

- `.dockerignore`
- `.env`
- Docker Compose
- Custom network
- MySQL healthcheck
- Flask healthcheck
- MySQL bind mount
- SQL initialization script
- Docker Hub

Image:

```text
snigdhach/multi-stage-flask-app:latest
```

## Weak Spot 1: CMD vs ENTRYPOINT

Practice with:

```dockerfile
ENTRYPOINT ["echo"]
CMD ["Hello Docker"]
```

Build:

```bash
docker build -t cmd-entrypoint-test .
```

Run:

```bash
docker run --rm cmd-entrypoint-test
```

Override the default CMD argument:

```bash
docker run --rm cmd-entrypoint-test "Hello DevOps"
```

The entrypoint remains `echo`, while the CMD argument changes.

## Weak Spot 2: Healthchecks and depends_on

Create an application and database service.

Add:

```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
  interval: 10s
  timeout: 5s
  retries: 5
```

Then:

```yaml
depends_on:
  db:
    condition: service_healthy
```

The key distinction is:

```text
depends_on  -> dependency
healthcheck -> health status
```

## Final Takeaways

- Images are read-only templates and containers are instances of images.
- Container writable-layer data is not persistent by default.
- Volumes and bind mounts provide persistence.
- Custom networks allow containers to communicate using names.
- Dockerfiles define how images are built.
- Multi-stage builds keep build dependencies out of the runtime image.
- Compose manages multi-container applications.
- `.env` provides configuration values to Compose.
- Healthchecks verify service health.
- `depends_on` defines service dependencies.
- Docker Hub can be used to publish and pull images.
- `docker system df` helps investigate Docker disk usage.
