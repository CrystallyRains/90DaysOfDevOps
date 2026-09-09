# Day 35: Multi-Stage Builds and Docker Hub

## What I Did Today

I worked on the frontend of the SocialPulse Social Network App (a Vite + React app) on my Ubuntu EC2 instance. I built a multi-stage Docker image, tagged it, pushed it to Docker Hub, and verified it by pulling it back.

## The Dockerfile I Used

The Dockerfile has two stages. The first stage builds the app and the second stage only carries the built output, so the final image stays small.

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS worker
WORKDIR /app
COPY --from=builder --chown=node:node /app/node_modules ./node_modules
COPY --from=builder --chown=node:node /app/dist ./dist
COPY --from=builder --chown=node:node /app/vite.config.js ./vite.config.js
USER node
EXPOSE 4173
CMD ["npx", "vite", "preview", "--host", "0.0.0.0"]
```

Best practices applied here: alpine base image, pinned node version (node:20-alpine instead of latest), multi-stage build so build tools do not bloat the final image, and a non-root USER node so the container does not run as root.

## Task 1 and 2: Building the Image

I built the image with:

```bash
docker build -t new-build:latest .
```

The build ran 14 steps. The builder stage installed 485 packages with npm ci and ran the Vite production build, which transformed 427 modules and produced dist assets including index-Ia2tD2zA.js at 528 kB. Vite warned that some chunks are larger than 500 kB and suggested code splitting with dynamic import() or manualChunks, which I can revisit later.

After the build, docker images showed:

| Image | ID | Disk Usage | Content Size |
|---|---|---|---|
| new-build:latest | a74657032075 | 649MB | 95.4MB |
| node:20-alpine | fb4cd12c85ee | 194MB | 48.8MB |

Why multi-stage helps: the builder stage holds npm, cache and all dev tooling, but the final image only copies node_modules, dist and vite.config.js. The content size of the final image is only 95.4MB even though the build environment is much heavier. The layer cache also helped: the second FROM node:20-alpine stage reused the cached WORKDIR layer, and later pushes reused existing layers.

## Task 3: Tagging and Pushing to Docker Hub

My first push attempt failed because docker push does not take a -t flag:

```bash
docker push -t new-build:latest snigdhach/multi-stage-frontend:v2
# unknown shorthand flag: 't' in -t
```

The correct flow is to tag first, then push:

```bash
docker tag new-build:latest snigdhach/multi-stage-frontend:v2
docker push snigdhach/multi-stage-frontend:v2
```

The push succeeded and printed the digest:

```
v2: digest: sha256:a746570320753829d7e865cc8afcea7188911ba2ac40b024287e0108e6ac42be
```

Key lesson: docker tag just creates another name pointing at the same image ID. After tagging, docker images showed new-build:latest and snigdhach/multi-stage-frontend:v2 sharing the same ID a74657032075.

## Task 4: Pulling, Tags and latest

I tried pulling latest before it existed and got an error:

```
docker pull snigdhach/multi-stage-frontend:latest
# not found
```

Pulling the v2 tag I had pushed worked and reported the image was up to date. Then I created a latest tag from the same image and pushed it:

```bash
docker tag new-build:latest snigdhach/multi-stage-frontend:latest
docker push snigdhach/multi-stage-frontend:latest
docker pull snigdhach/multi-stage-frontend
```

Since latest is the default tag, a plain docker pull without a tag now works. What I learned about versioning: latest is just another tag, it is not automatically updated when I push a new version, so I must explicitly retag and push latest myself. My repo now has v1, v2 and latest, and v2 and latest point at the same image.

## Docker Hub Repository

My repository is https://hub.docker.com/r/snigdhach/multi-stage-frontend with the description "Multi-stage Vite frontend image built with Node.js Alpine." Repository size is 135.8 MB with tags latest, v2 and v1.

## Running the Container

From earlier attempts (history commands 86 to 99) I learned to map the container port correctly:

```bash
docker run -d -p 4173:4173 snigdhach/multi-stage-frontend:v1
curl http://localhost:4173
```

An earlier run on the wrong port showed as exited in docker ps -a, and I checked docker logs <container-id> to debug, then stopped and removed the container.

## Extra Lessons from Today's Session

- docker push does not accept -t. Always tag first with docker tag, then push by the full name.
- All tags pointing at the same image ID share layers, so pushing latest after v2 pushed instantly because every layer already existed.
- docker system prune cleared dangling images and build cache when disk usage got high.
- The legacy builder is deprecated, so I should install buildx for BuildKit.
- Typo lesson: I typed historu instead of history, and earlier ptyhon instead of python. Small typos cost time.

## Commands Cheat Sheet for Revision

```bash
docker build -t name:tag .              # build image from Dockerfile
docker images                            # list images with IDs and sizes
docker tag local:tag user/repo:tag       # rename for Docker Hub
docker push user/repo:tag                # upload to Docker Hub
docker pull user/repo:tag                # download from Docker Hub
docker run -d -p host:container image    # run container detached with port mapping
docker ps / docker ps -a                 # list running / all containers
docker logs <id>                         # view container logs
docker stop <id> && docker rm <id>       # stop and remove container
docker rmi image:tag                     # remove an image
docker system prune                      # clean dangling images and cache
```

## Notes for Future Me

To revise this topic: rebuild with docker build -t new-build:latest . inside the frontend folder, retag to snigdhach/multi-stage-frontend with a new version number, push both that version and latest, then pull on a fresh machine to verify. Remember the digest identifies the exact image content, and both v2 and latest here carry digest sha256:a74657032075.

