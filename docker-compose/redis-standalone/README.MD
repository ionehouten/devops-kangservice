# Redis Standalone with Docker Compose

[![Docker](https://img.shields.io/badge/Docker-Container-blue?logo=docker)](https://www.docker.com/)
[![Redis](https://img.shields.io/badge/Redis-8-red?logo=redis)](https://redis.io/)
[![DevOps](https://img.shields.io/badge/DevOps-Lab-purple)]()
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Mac%20%7C%20Windows-lightgrey)]()
![Maintenance](https://img.shields.io/badge/Maintained-yes-green.svg)
![GitHub stars](https://img.shields.io/github/stars/ionehouten/devops-kangservice?style=social)

This example demonstrates how to run a **Redis standalone instance** using Docker Compose.

The project supports:

- Redis with **ACL authentication**
- Redis with **TLS encryption**
- Automatic **setup script**
- **Makefile commands** for easier development workflow

---

## Features

- Redis ACL multi-user authentication
- Optional hashed password ACL
- TLS secure Redis
- Automatic storage preparation
- Docker Compose deployment
- DevOps-friendly setup workflow

---

## Requirements

- Docker
- Docker Compose
- OpenSSL
- Make (optional)

---

## Project Files

- `docker-compose.yml` — run Redis without TLS
- `docker-compose.yml-tls` — run Redis with TLS
- `env.example` — environment configuration template
- `setup-redis.sh` — setup script for storage, ACL, and TLS
- `Makefile` — helper commands
- `certs/` — TLS certificates directory
- `users.acl` — Redis ACL file (generated)

---

## Quick Start

Copy environment configuration:

```bash
cp env.example .env
```

Run setup:

```bash
make setup
```

Start Redis:

```bash
make up
```

Or start Redis with TLS:

```bash
make up-tls
```

---

## Manual Setup (Without Make)

If `make` is not installed, you can run the setup script directly.

Make the script executable:

```bash
chmod +x setup-redis.sh
```

Run full setup:

```bash
./setup-redis.sh all
```

Start Redis:

```bash
docker compose up -d
```

Or with TLS:

```bash
docker compose -f docker-compose.yml-tls up -d
```

---

## Environment Configuration

The `env.example` file defines required environment variables.

Example:

```bash
DOCKER_VOLUME_DIRECTORY=/data/docker-compose/volumes/redis
REDIS_ADMIN_PASSWORD=supersecureadmin
REDIS_READONLY_PASSWORD=readonly
REDIS_APP_PASSWORD=appsecure
REDIS_PORT=6379
REDIS_TLS_PORT=6380
```

Before running Redis:

```bash
cp env.example .env
```

---

## Redis ACL Configuration

This project uses **Redis ACL (Access Control List)** for authentication.

Example ACL configuration:

```conf
user admin on >password ~* +@all
user readonly on >password ~* +get +info +exists +ping +scan
user appadmin on >password ~* +@write +@read -@dangerous
user appuser on >password ~app:* +get +set +del +expire +ttl
user default off
```

Users:

| User | Permission |
|-----|------------|
| admin | Full access |
| readonly | Read-only commands |
| appadmin | Read/write without dangerous commands |
| appuser | Limited access to `app:*` keys |

---

## TLS Setup

TLS certificates can be generated automatically.

Run:

```bash
make cert
```

Or:

```bash
./setup-redis.sh cert
```

Generated files:

```
certs/
├── ca.crt
├── ca.key
├── redis.crt
└── redis.key
```

---

## Connecting to Redis

### Enter the Redis container

```bash
docker exec -it redis-server bash
```

### Without TLS
```
redis-cli -h localhost -p 6379
```

---
### With TLS
```
redis-cli \
  --tls \
  --cacert certs/ca.crt \
  -h localhost \
  -p 6380
```

Test connection:

```
PING
```

Expected response:

```
PONG
```

---

## Makefile Commands

Available commands:

```
make setup      # prepare storage, ACL, TLS
make storage    # prepare volume directory
make acl        # generate users.acl
make acl-hash   # generate users-hash.acl
make cert       # generate TLS certificates

make up         # start Redis without TLS
make up-tls     # start Redis with TLS

make down       # stop Redis
make logs       # view logs
```

---

## Storage Preparation

Redis requires correct filesystem permissions for persistent storage.

The setup script automatically prepares the directory defined in:

```
DOCKER_VOLUME_DIRECTORY
```

It also sets the correct Redis container permissions:

```
UID 999
GID 999
```

---

## Stop Redis

Stop containers:

```
make down
```

Or manually:

```
docker compose down
```

---

## Windows Support

`make` is not installed by default on Windows.

Options:

1. Use **WSL (Windows Subsystem for Linux)**
2. Install `make` via **Chocolatey**
3. Install `make` via **Scoop**

If `make` is unavailable, run the script directly:

```
./setup-redis.sh all
docker compose up -d
```

---

## Use Cases

This example is useful for:

- Learning Redis with Docker Compose
- Testing Redis ACL authentication
- Testing TLS-secured Redis
- DevOps practice environments
- Local development setup

---

## License

MIT