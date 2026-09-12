# Day 35: Dockerize a Full Application

## What I Worked On

Dockerized a two-tier Flask + MySQL application using:

- Docker
- Multi-stage Docker builds
- Docker Compose
- MySQL
- Custom Docker network
- Persistent storage
- Environment variables
- Healthchecks
- Docker Hub

The application was cloned from my GitHub repository:

`https://github.com/CrystallyRains/two-tier-flask-app`

## Application

The application has two main components:

```text
Flask Application
       |
       v
     MySQL
```

The Flask application connects to MySQL using environment variables:

```python
MYSQL_HOST
MYSQL_USER
MYSQL_PASSWORD
MYSQL_DB
```

The MySQL service is reachable using the Compose service name:

```text
mysql
```

Docker Compose provides internal DNS, so the Flask container can connect to MySQL using `MYSQL_HOST=mysql`.

---

## Dockerfile

I used a multi-stage Docker build.

### Builder Stage

The builder uses Python 3.14 and installs the dependencies required to build the application.

```dockerfile
FROM python:3.14 AS builder

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc default-libmysqlclient-dev pkg-config && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt
```

### Runner Stage

The final image uses Docker Hardened Image:

```dockerfile
FROM dhi.io/python:3

WORKDIR /app

COPY --from=builder /usr/local/lib/python3.14/site-packages/ /usr/local/lib/python3.14/site-packages/

COPY . .

CMD ["python", "app.py"]
```

### Why Multi-stage?

The builder contains the packages and tools needed to install Python dependencies.

The final stage only contains the application and the Python runtime, which helps reduce the final image and keeps build tools out of the runtime image.

---

## Docker Hardened Image

I used:

```text
dhi.io/python:3
```

The DHI Python image already runs as a non-root user.

Verified with:

```bash
docker run --rm dhi.io/python:3 python -c "import os; print('UID:', os.getuid()); print('GID:', os.getgid())"
```

Output:

```text
UID: 65532
GID: 65532
```

The user is:

```text
nonroot
```

Therefore, I did not need to add a separate `USER` instruction in the final stage.

---

## Important DHI Learning

The DHI runtime image does not contain `/bin/sh`.

Therefore, commands such as:

```dockerfile
RUN apt-get update
```

should not be placed in the DHI runner stage.

System packages required by the application were installed in the builder stage instead.

The builder and runner Python versions also need to match when copying `site-packages`.

Final setup:

```text
Builder: python:3.14
Runner:  dhi.io/python:3
```

The Python packages were copied from:

```text
/usr/local/lib/python3.14/site-packages/
```

---

## .dockerignore

I used `.dockerignore` to avoid sending unnecessary files to the Docker build context.

```dockerignore
.git
.gitignore
.github
__pycache__
*.pyc
*.pyo
*.pyd
.Python
.pytest_cache
.venv
venv
.env
.env.*
Dockerfile
.dockerignore
README.md
*.md
```

It is especially important to exclude:

```text
.env
```

so environment variables and secrets are not copied into the image.

---

## Docker Compose

The application was configured with two services:

```text
flask-app
mysql
```

Final Compose structure:

```yaml
services:

  flask-app:
    container_name: flask-app
    build:
      context: ./
    ports:
      - "5000:5000"
    depends_on:
      - mysql
    networks:
      - two-tier-ntw
    environment:
      MYSQL_PASSWORD: "${MYSQL_PASSWORD}"
      MYSQL_DB: "${MYSQL_DB}"
      MYSQL_HOST: "${MYSQL_HOST}"
      MYSQL_USER: "${MYSQL_USER}"
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:5000/health || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 5s

  mysql:
    image: mysql:8.0
    container_name: mysql
    volumes:
      - ./mysql-data:/var/lib/mysql
      - ./message.sql:/docker-entrypoint-initdb.d/message.sql
    networks:
      - two-tier-ntw
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: "${MYSQL_DB}"
      MYSQL_USER: "${MYSQL_USER}"
      MYSQL_PASSWORD: "${MYSQL_PASSWORD}"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-uroot", "-proot"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 5s

networks:
  two-tier-ntw:
```

---

## Environment Variables

The `.env` file keeps the Compose configuration separate from the actual values.

```env
MYSQL_PASSWORD=admin
MYSQL_DB=devops
MYSQL_USER=admin
MYSQL_HOST=mysql
```

Compose automatically reads the `.env` file from the project directory.

The same variables are passed to the Flask container and used by the application to connect to MySQL.

---

## Volumes

The MySQL service uses two bind mounts:

```yaml
volumes:
  - ./mysql-data:/var/lib/mysql
  - ./message.sql:/docker-entrypoint-initdb.d/message.sql
```

### MySQL Data

```text
./mysql-data:/var/lib/mysql
```

This keeps MySQL data outside the container filesystem so the data can persist when the container is recreated.

### SQL Initialization

```text
./message.sql:/docker-entrypoint-initdb.d/message.sql
```

The SQL file is mounted into MySQL's initialization directory.

A bind mount does not require a separate top-level `volumes:` declaration.

---

## Custom Network

Both services use:

```yaml
networks:
  - two-tier-ntw
```

The network is declared at the bottom of the Compose file:

```yaml
networks:
  two-tier-ntw:
```

This allows the Flask and MySQL containers to communicate over the same custom Docker network.

The Flask application does not use:

```text
localhost
```

for MySQL.

Instead:

```env
MYSQL_HOST=mysql
```

because `mysql` is the Compose service name.

---

## Healthchecks

### Flask

```yaml
healthcheck:
  test: ["CMD-SHELL", "curl -f http://localhost:5000/health || exit 1"]
  interval: 10s
  timeout: 5s
  retries: 5
  start_period: 5s
```

The health endpoint is checked using `curl`.

### MySQL

```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-uroot", "-proot"]
  interval: 10s
  timeout: 5s
  retries: 5
  start_period: 5s
```

The MySQL healthcheck verifies that the database is responding.

---

## Building and Running

Build the application image:

```bash
docker build -t multi-stage-flask-app:latest .
```

Check images:

```bash
docker images
```

Run the application with Compose:

```bash
docker compose up -d
```

Check running containers:

```bash
docker ps
```

Check logs:

```bash
docker compose logs
```

Stop the application:

```bash
docker compose down
```

---

## Challenges and Important Learnings

### 1. DHI Runtime Does Not Have `/bin/sh`

The first runtime-stage attempt tried to install packages with `apt-get` inside the DHI image.

The build failed because the DHI image does not provide `/bin/sh`.

Fix:

- Install required build dependencies in the builder stage.
- Keep the DHI runner stage minimal.
- Do not use shell-based package installation in the DHI runner.

### 2. Python Version Alignment

The builder initially used Python 3.9 while the final DHI image uses Python 3.x with Python 3.14 in the tested image.

The copied dependency path therefore had to match the builder version.

Final path:

```text
/usr/local/lib/python3.14/site-packages/
```

### 3. Limited EC2 Disk Space

The EC2 instance had a small root filesystem of around 6.7 GB.

Docker builds can temporarily require much more space than the final image because intermediate layers and build cache also consume storage.

Useful commands for investigating Docker and disk usage:

```bash
docker system df
df -h
sudo du -xhd1 /var
sudo du -xhd1 /var/lib
sudo du -xhd1 /var/snap
```

Cleanup commands used:

```bash
docker system prune -a
docker volume prune
sudo apt clean
```

Key lesson: Docker build failures caused by `no space left on device` can be related to temporary build storage and the overall host filesystem, not only the final Docker image size.

---

## Docker Hub

The final multi-stage image was tagged and pushed to Docker Hub:

```bash
docker tag multi-stage-flask-app:latest snigdhach/multi-stage-flask-app:latest

docker push snigdhach/multi-stage-flask-app:latest
```

Docker Hub repository:

`https://hub.docker.com/r/snigdhach/multi-stage-flask-app`

Image:

```text
snigdhach/multi-stage-flask-app:latest
```

---

## Git

The project was committed and pushed to GitHub.

```bash
git add .
git commit -m "Added multistage docker build"
git push origin main
```

---

## Final Architecture

```text
                         Docker Compose
                              |
                +-------------+-------------+
                |                           |
                v                           v
          Flask Container            MySQL Container
          flask-app                  mysql:8.0
                |                           |
                |                           |
                +------ two-tier-ntw -------+
                                            |
                                     ./mysql-data
                                            |
                                     Persistent Data

Flask:
  Port 5000
  Python 3.14
  DHI Python runtime
  Non-root user

MySQL:
  Port 3306 internally
  MySQL 8.0
  Persistent bind mount
  SQL initialization script
```

## Key Takeaways

- Multi-stage builds separate build dependencies from the runtime image.
- The runtime image should contain only what is required to run the application.
- DHI images can provide a non-root runtime by default.
- Builder and runtime compatibility matters when copying Python dependencies.
- `.dockerignore` keeps the build context clean and prevents `.env` from entering the image.
- Compose makes it easier to run multi-container applications.
- Compose service names can be used for container-to-container communication.
- Bind mounts can persist database data outside the container filesystem.
- Healthchecks help determine whether services are actually healthy.
- Docker builds need sufficient host disk space for layers, cache and temporary files.
- Docker Hub allows the built image to be shared and reused outside the local environment.
