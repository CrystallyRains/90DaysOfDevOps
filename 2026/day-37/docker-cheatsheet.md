# Docker Cheat Sheet

## Container Commands

```bash
docker run nginx
```
Run a container.

```bash
docker run -it ubuntu bash
```
Run interactively.

```bash
docker run -d nginx
```
Run in detached mode.

```bash
docker run -d --name app -p 8080:80 nginx
```
Run with a custom name and port mapping.

```bash
docker ps
```
List running containers.

```bash
docker ps -a
```
List all containers.

```bash
docker stop <container>
```
Stop a container.

```bash
docker rm <container>
```
Remove a stopped container.

```bash
docker exec -it <container> bash
```
Open a shell inside a running container.

```bash
docker logs <container>
```
View container logs.

## Image Commands

```bash
docker images
```
List local images.

```bash
docker build -t my-app:latest .
```
Build and tag an image.

```bash
docker pull nginx:latest
```
Pull an image.

```bash
docker tag my-app:latest username/my-app:latest
```
Tag an image for a registry.

```bash
docker push username/my-app:latest
```
Push an image.

```bash
docker rmi <image>
```
Remove a local image.

## Volume Commands

```bash
docker volume create app-data
```
Create a named volume.

```bash
docker volume ls
```
List volumes.

```bash
docker volume inspect app-data
```
Inspect a volume.

```bash
docker volume rm app-data
```
Remove a volume.

```bash
docker run -v app-data:/data nginx
```
Mount a named volume.

```bash
docker run -v $(pwd):/app nginx
```
Use a bind mount.

## Network Commands

```bash
docker network create app-network
```
Create a custom network.

```bash
docker network ls
```
List networks.

```bash
docker network inspect app-network
```
Inspect a network.

```bash
docker network connect app-network <container>
```
Connect a running container to a network.

## Compose Commands

```bash
docker compose up
```
Create and start services.

```bash
docker compose up -d
```
Start services in detached mode.

```bash
docker compose down
```
Stop and remove Compose containers and networks.

```bash
docker compose down -v
```
Also remove named volumes created by the Compose project.

```bash
docker compose ps
```
Show Compose service status.

```bash
docker compose logs
```
View Compose logs.

```bash
docker compose logs -f
```
Follow Compose logs.

```bash
docker compose build
```
Build Compose images.

## Cleanup and Disk Usage

```bash
docker system df
```
Show Docker disk usage.

```bash
docker system df -v
```
Show detailed Docker disk usage.

```bash
docker container prune
```
Remove stopped containers.

```bash
docker image prune
```
Remove dangling images.

```bash
docker volume prune
```
Remove unused volumes.

```bash
docker network prune
```
Remove unused networks.

```bash
docker system prune
```
Remove unused Docker data.

```bash
docker system prune -a
```
Remove unused images and other unused Docker data.

```bash
df -h
```
Check host filesystem usage.

## Dockerfile Instructions

```dockerfile
FROM python:3.14
```
Set the base image.

```dockerfile
WORKDIR /app
```
Set the working directory.

```dockerfile
RUN pip install -r requirements.txt
```
Run a command during image build.

```dockerfile
COPY . .
```
Copy files into the image.

```dockerfile
EXPOSE 5000
```
Document the application port.

```dockerfile
CMD ["python", "app.py"]
```
Set the default command.

```dockerfile
ENTRYPOINT ["python"]
```
Set the main executable.

## Multi-stage Build

```dockerfile
FROM python:3.14 AS builder
```
Create a builder stage.

```dockerfile
COPY --from=builder /source /destination
```
Copy files from another build stage.

## Quick Reminders

```text
Image       -> read-only template
Container   -> instance of an image
Volume      -> Docker-managed persistent storage
Bind mount  -> host path mounted into container
Network     -> container communication
Compose     -> multi-container application management
Healthcheck -> service health verification
.env        -> Compose configuration values
.dockerignore -> files excluded from build context
```
