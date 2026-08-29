# Day 32 – Docker Volumes & Networking

## Overview

Today I worked with two important Docker concepts:

- **Data persistence** using volumes and bind mounts
- **Container-to-container communication** using Docker networks

The main takeaway was that containers are temporary, but data does not have to be.

---

## Task 1: The Problem – Container Data Is Ephemeral

I started a MySQL container without explicitly creating a named volume:

```bash
docker run -d --name mysql-test -e MYSQL_ROOT_PASSWORD=root -p 3306:3306 mysql
```

I connected to MySQL:

```bash
docker exec -it mysql-test mysql -uroot -proot
```

I created a database and table and inserted data:

```sql
CREATE DATABASE testdb;

USE testdb;

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50)
);

INSERT INTO users (name)
VALUES ('Snigdha'), ('Docker'), ('DevOps');

SELECT * FROM users;
```

The data was present.

I then stopped and removed the container:

```bash
docker stop mysql-test
docker rm mysql-test
```

When I created a new MySQL container, the previous database data was not available.

### What happened?

The data was stored in the container's writable layer. When the container was removed, that layer was removed as well.

**Conclusion:** Containers are ephemeral. If important data is stored only inside the container, removing the container can remove that data.

---

# Task 2: Named Volumes

## Create a named volume

```bash
docker volume create named-vol
```

Verify:

```bash
docker volume ls
```

## Run MySQL with the volume

```bash
docker run -d \
  --name mysql-persistent \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=testdb \
  -v named-vol:/var/lib/mysql \
  mysql
```

The important part is:

```bash
-v named-vol:/var/lib/mysql
```

This attaches the Docker-managed named volume to MySQL's data directory.

## Add data

```bash
docker exec -it mysql-persistent mysql -uroot -proot
```

Then:

```sql
USE testdb;

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50)
);

INSERT INTO users (name)
VALUES ('Snigdha'), ('Docker'), ('DevOps');

SELECT * FROM users;
```

I then stopped and removed the container:

```bash
docker stop mysql-persistent
docker rm mysql-persistent
```

The container was removed, but the named volume remained.

I created a brand-new container using the same volume:

```bash
docker run -d \
  --name mysql-persistent-new \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=testdb \
  -v named-vol:/var/lib/mysql \
  mysql
```

Then:

```bash
docker exec -it mysql-persistent-new mysql -uroot -proot
```

```sql
USE testdb;
SELECT * FROM users;
```

The previously created data was still available.

### Conclusion

A named volume exists independently of the container.

```text
Container 1
    |
    v
named-vol
    ^
    |
Container 2
```

Removing Container 1 does not remove `named-vol`, so Container 2 can reuse the same data.

### Verification

```bash
docker volume ls
docker volume inspect named-vol
```

---

# Task 3: Bind Mounts

I created a folder on the host containing an `index.html` file.

I then ran Nginx with the host directory mounted into Nginx's web directory:

```bash
docker run -d \
  --name nginx-bind \
  -p 8080:80 \
  -v /path/to/task4:/usr/share/nginx/html \
  nginx:alpine
```

The important part is:

```bash
-v /path/to/task4:/usr/share/nginx/html
```

Here:

- `/path/to/task4` = directory on the host
- `/usr/share/nginx/html` = directory inside the container

I accessed the page through the browser.

I then edited `index.html` on the host and refreshed the browser. The updated content appeared immediately.

### Named Volume vs Bind Mount

| Named Volume | Bind Mount |
|---|---|
| Managed by Docker | Uses a specific host path |
| Docker manages where the data is stored | User controls the host directory |
| Commonly used for persistent application/database data | Useful for development and sharing host files with containers |
| `named-vol:/var/lib/mysql` | `/path/to/site:/usr/share/nginx/html` |

The key difference is **who controls the storage location**.

---

# Task 4: Docker Networking Basics

## List Docker networks

```bash
docker network ls
```

This showed the Docker networks available on the machine, including the default `bridge`, `host`, and `none` networks.

## Inspect the default bridge

```bash
docker network inspect bridge
```

This showed information such as the network ID, driver, subnet, gateway, and connected containers.

## Test containers on the default bridge

I ran two containers on the default `bridge` network.

### Name-based communication

Containers on the default bridge do not provide the same automatic container-name DNS resolution as a user-defined bridge network.

Therefore, trying to communicate using the other container's name did not work as expected.

### IP-based communication

I inspected the network and obtained the container IP addresses:

```bash
docker network inspect bridge
```

Communication using the container IP was possible.

### Conclusion

The default `bridge` network provides network connectivity, but it does not provide the same convenient automatic name-based DNS behavior available on a custom bridge network.

---

# Task 5: Custom Networks

## Create a custom bridge network

```bash
docker network create my-app-net
```

## Run containers on the custom network

```bash
docker run -dit --name container1 --network my-app-net ubuntu bash
docker run -dit --name container2 --network my-app-net ubuntu bash
```

## Test name-based communication

I tested communication between the containers using the container name.

On a user-defined bridge network, Docker provides built-in DNS-based service discovery.

This means:

```text
container1 ---> container2
                 ^
                 |
              DNS name
```

Docker can resolve `container2` to its current IP address.

### Why does custom networking allow name-based communication?

A user-defined bridge network provides built-in DNS resolution between containers on that network.

So when one container tries to reach:

```text
container2
```

Docker resolves the name to the container's IP address.

This is useful because containers can be recreated and their IP addresses can change. Applications do not need to hard-code those IP addresses; they can communicate using container or service names.

The default bridge network does not provide this same automatic name-based DNS behavior.

---

# Task 6: Put It Together

## Create a custom network

```bash
docker network create my-net
```

## Run a database container

I used MySQL with a named volume:

```bash
docker volume create named-vol-2
```

```bash
docker run -d \
  --name cont1 \
  -v named-vol-2:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=root \
  --network my-net \
  mysql
```

The database container was connected to `my-net`, and its data directory was backed by `named-vol-2`.

I verified the database and created test data:

```bash
docker exec -it cont1 mysql -uroot -proot
```

```sql
CREATE DATABASE testdb;

USE testdb;

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50)
);

INSERT INTO users (name)
VALUES ('Snigdha'), ('Docker'), ('DevOps');

SELECT * FROM users;
```

The data was successfully stored in the database.

## Run an application container

I used Ubuntu as the application container:

```bash
docker run -dit \
  --name app1 \
  --network my-net \
  ubuntu bash
```

Inside the application container, I installed the MySQL client:

```bash
apt update
apt install -y mysql-client
```

## Verify communication

Both containers were connected to the same custom network:

```text
                my-net
        ┌─────────────────────┐
        │                     │
        │   app1 ─────────> cont1
        │                     │
        │                   MySQL
        │                     │
        │                named-vol-2
        └─────────────────────┘
```

The application container can reach the database using the database container's name:

```bash
mysql -h cont1 -uroot -proot
```

This demonstrates how Docker networking allows an application to communicate with a database without needing to know the database container's IP address.

---

# Key Learnings

## 1. Containers are ephemeral

If data exists only inside a container's writable layer, removing the container removes that data.

## 2. Volumes provide persistence

A named volume exists independently of a container and can be mounted into a new container.

```bash
-v named-vol:/var/lib/mysql
```

## 3. Bind mounts connect host files to containers

Bind mounts are useful when the host needs direct control over the files.

```bash
-v /host/path:/container/path
```

## 4. Docker networks enable container communication

Containers connected to the same network can communicate with each other.

## 5. Custom bridge networks provide DNS-based service discovery

With a user-defined bridge network, containers can communicate using names instead of relying on changing IP addresses.

---

# Final Takeaway

The two major problems solved today were:

### Data persistence

```text
Container
    ↓
Named Volume
    ↓
Data survives container removal
```

### Container communication

```text
App Container
      ↓
Custom Docker Network
      ↓
Database Container
```

Together, volumes and networking form the foundation of running multi-container applications with Docker.

---

# Useful Commands

## Volumes

```bash
docker volume create <volume>
docker volume ls
docker volume inspect <volume>
docker volume rm <volume>
```

## Bind Mount

```bash
docker run -v /host/path:/container/path ...
```

## Networks

```bash
docker network ls
docker network inspect bridge
docker network create <network>
docker network inspect <network>
```

## Connect a container to a network

```bash
docker run --network <network> ...
```

## Inspect a container's mounts and network

```bash
docker inspect <container>
```

---

# Screenshots

Screenshots of the experiments can be added to this directory:

- Container data disappearing after container removal
- Named volume creation and inspection
- Data surviving container recreation with the same volume
- Nginx bind mount
- Host `index.html` update reflected in the browser
- Default bridge network inspection
- Default bridge name/IP communication tests
- Custom network and name-based communication
- Database + application container communication
