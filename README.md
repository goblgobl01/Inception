*This project has been created as part of the 42 curriculum by mmaarafi.*

# Inception

## Description

Inception is a system administration project from the 42 curriculum. The goal is to set up a small but fully functional web infrastructure using Docker and Docker Compose, running inside a virtual machine. The stack consists of three services — NGINX, WordPress + PHP-FPM, and MariaDB — each isolated in its own container, communicating over a private Docker network, with persistent data stored in named volumes.

### Project Design Choices

**Virtual Machines vs Docker**

A Virtual Machine (VM) emulates a full operating system with its own kernel, providing strong isolation but at a heavy resource cost. Docker containers, by contrast, share the host kernel and package only the application and its dependencies, making them far lighter and faster to spin up. This project uses Docker because it's ideal for deploying isolated services efficiently without the overhead of full OS virtualization.

**Secrets vs Environment Variables**

Environment variables (stored in a `.env` file) are convenient for non-sensitive configuration like domain names or usernames. For sensitive data such as passwords and API keys, Docker Secrets are preferred — they are stored in memory (tmpfs) inside the container and never written to the image layers or environment, making them significantly more secure. This project uses both: `.env` for general config and a `secrets/` folder (gitignored) for credentials.

**Docker Network vs Host Network**

Using `network: host` makes a container share the host's network namespace directly, bypassing Docker's isolation entirely. A custom Docker bridge network (as used in this project) gives containers their own isolated network where they can communicate by service name (DNS resolution) without exposing internal ports to the outside world. The only exposed port is 443 on NGINX.

**Docker Volumes vs Bind Mounts**

Bind mounts map a specific host path into the container, making them tightly coupled to the host filesystem structure. Named Docker volumes are managed by Docker itself, are more portable, and are the recommended approach for persistent data in production-like setups. This project uses named volumes for the WordPress files and the MariaDB database, stored under `/home/mmaarafi/data` on the host.


## Instructions

### Prerequisites

- A Linux virtual machine (Debian or Ubuntu recommended)
- Docker and Docker Compose installed
- `make` installed
- but the domain mmaarafi.42.fr in `/etc/hosts` pointing to `127.0.0.1`

### Setup

**1. Clone the repository:**
```bash
git clone git@vogsphere.1337.ma:vogsphere/intra-uuid-d9dfae01-d172-4a1e-9e32-ff0438ad81eb-7370183-mmaarafi
cd inception
```

**2. Add your domain to `/etc/hosts` on the VM:**
```bash
echo "127.0.0.1 mmaarafi.42.fr" | sudo tee -a /etc/hosts
```

**3. Create the `.env` file** at `srcs/.env` (see `srcs/.env.example` for the required variables):
```
MYSQL_USER = mmaarafi
MYSQL_PASSWORD = strong_password
MYSQL_DATABASE = wordpress
MYSQL_ROOT_PASSWORD = strong_root_password
DOMAIN_NAME = mmaarafi.42.fr
WP_ADMIN_USER = ad_user
WP_ADMIN_PASSWORD = ad_password
WP_USER = mmaarafi
WP_ADMIN_EMAIL=ad@mmaarafi.42.fr
WP_USER_EMAIL=user@mmaarafi.42.fr
WP_USER_PASSWORD = user_password
```

**4. Build and start:**
```bash
make
```

**5. Visit the site:**

Open your browser and go to `https://mmaarafi.42.fr`. Accept the self-signed certificate warning.

### Makefile targets

| Target | Description |
|---|---|
| `make` / `make all` | Build images and start all containers |
| `make stop` | Stop and remove containers and images |
| `make re` | Full rebuild from scratch |

---

## Resources

### Docker & Infrastructure
- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB Docker Hub](https://hub.docker.com/_/mariadb)
- [WordPress + PHP-FPM setup guide](https://make.wordpress.org/hosting/handbook/server-environment/)
- [Understanding PID 1 in containers](https://cloud.google.com/architecture/best-practices-for-building-containers#signal-handling)
- [TLSv1.2/1.3 with NGINX](https://nginx.org/en/docs/http/ngx_http_ssl_module.html)
- [Docker Secrets documentation](https://docs.docker.com/engine/swarm/secrets/)

### AI Usage

AI (Claude) was used in this project for the following tasks:

- **Documentation**: Generating the initial drafts of `README.md`, `USER_DOC.md`, and `DEV_DOC.md`, which were then reviewed and adjusted to match the actual project configuration.
- **Dockerfile patterns**: Getting an overview of best practices for running services as PID 1 (using `exec` form of `CMD`/`ENTRYPOINT`) and avoiding infinite-loop hacks.
- **Nginx SSL config**: Generating a starting nginx.conf with TLSv1.2/1.3 restrictions, reviewed and tested manually.
- **Debugging**: Explaining error messages encountered during `docker compose up` and suggesting fixes.

All AI-generated content was reviewed, understood, and validated before being included in the project. Nothing was blindly copy-pasted without comprehension.