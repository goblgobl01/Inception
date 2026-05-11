# DEV_DOC.md — Developer Documentation

This document describes how to set up, build, and manage the Inception project from a developer's perspective.

---

## Environment Setup from Scratch

### Prerequisites

- A Linux virtual machine (Debian 11/12 or Alpine 3.x recommended)
- Docker Engine installed: [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)
- Docker Compose v2 (comes bundled with Docker Desktop or installable via `apt`)
- `make` installed (`sudo apt install make`)
- Git

### Repository Structure

```
inception/
├── Makefile
├── README.m
├── USER_DOC.md
├── DEV_DOC.md
└── srcs/
    ├── .env
    ├── docker-compose.yml
    ├── nginx/
    │   ├── Dockerfile
    │   ├── conf/nginx.conf
    |   └── tools/script.sh
    ├── WordPress/
    │   ├── Dockerfile
    |   └── tools/wordpress_script.sh
    ├── MariaDB/
    |   ├── Dockerfile
    │   ├── conf/config.cnf
    |   └── tools/maria_script.sh
```

### Configuration Files

**1. Create `srcs/.env`** — copy and fill in all values:
```bash
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

Rules from the subject:
- `ADMIN_USER` must NOT contain `admin`, `Admin`, `administrator`, or `Administrator`
- Never commit `.env` to Git  it is listed in `.gitignore`

**2. Add your domain to `/etc/hosts` on the VM:**
```bash
echo "127.0.0.1 mmaarafi.42.fr" | sudo tee -a /etc/hosts
```

---

## Building and Launching with Makefile and Docker Compose

**First build and start:**
```bash
make
```
Internally runs:
```bash
docker compose -f ./srcs/docker-compose.yml up -d --build
```
- `--build` forces image rebuild even if cached
- `-d` runs in detached (background) mode

**Full clean rebuild:**
```bash
make re
```
Stops containers, removes images, then rebuilds from scratch.

**Nuclear reset (wipe everything including data):**
```bash
docker compose -f ./srcs/docker-compose.yml down -v && docker system prune -af
make
```

---

## Container Management Commands

**See running containers:**
```bash
docker ps
```

**See all containers including stopped:**
```bash
docker ps -a
```

**Follow logs in real time:**
```bash
docker logs -f wordpress
docker logs -f mariadb
docker logs -f nginx
```

**Shell into a running container:**
```bash
docker exec -it wordpress bash
docker exec -it mariadb bash
docker exec -it nginx bash
```

**Restart a single service:**
```bash
docker restart wordpress
```

**Rebuild and restart a single service only:**
```bash
docker compose -f ./srcs/docker-compose.yml up -d --build wordpress
```

**Inspect the Docker network:**
```bash
docker network inspect srcs_inception
```

---

## Data Storage and Persistence

### Named Volumes

The project uses two Docker named volumes:

| Volume | Mounted at | Contains |
|---|---|---|
| `srcs_wordpress` | `/var/www/html` in wordpress and nginx | WordPress core files, themes, plugins, uploads |
| `srcs_mariadb` | `/var/lib/mysql` in mariadb | All MariaDB database files |

**Inspect a volume:**
```bash
docker volume inspect srcs_wordpress
docker volume inspect srcs_mariadb
```

**List all volumes:**
```bash
docker volume ls
```

### How Persistence Works

When you run `docker compose down` (without `-v`), containers are destroyed but volumes remain. On the next `make`, containers are recreated and reattach to the existing volumes  all WordPress content and database data survives.

The init scripts are idempotent:
- `maria_script.sh` checks `if [ ! -d "/var/lib/mysql/${SQL_DATABASE}" ]` — skips DB setup if already initialized
- `wordpress_script.sh` checks `if [ ! -f /var/www/html/wp-config.php ]` — skips WordPress install if already configured

**Delete volumes (all data lost):**
```bash
docker compose -f ./srcs/docker-compose.yml down -v
```

### Where Docker Stores Volume Data on the Host

it is stored on /home/mmaarafi/data/ and you can check by runing this 

```bash
# Find the actual path on the host:
docker volume inspect srcs_wordpress 
#or 
docker volume inspect srcs_mariadb 
# Returns something like: /var/lib/docker/volumes/srcs_wordpress/_data
```

---

## How the Startup Sequence Works

Understanding the boot order helps debug issues:

```
1. MariaDB container starts
   └── maria_script.sh runs
       ├── If fresh volume: initializes DB, creates user, sets root password
       └── exec mysqld (becomes PID 1, ready for connections on port 3306)

2. WordPress container starts (depends_on: mariadb)
   └── wordpress_sript.sh runs
       ├── Patience loop: pings MariaDB every 2s until ready
       ├── If fresh volume: downloads WordPress, creates wp-config.php, installs WP, creates users
       └── exec php-fpm8.2 -F (becomes PID 1, listens on port 9000)

3. NGINX container starts (depends_on: wordpress)
   └── nginx -g 'daemon off;' (becomes PID 1, listens on port 443)
       └── Forwards .php requests to wordpress:9000 via FastCGI
```

---

## Common Debug Commands

```bash
# Check if MariaDB DB was created:
docker exec -it mariadb mariadb -uroot -p"{root password here}" -e "SHOW DATABASES;"

# Check WordPress files exist:
docker exec -it wordpress ls /var/www/wordpress

# Check wp-config.php was created:
docker exec -it wordpress cat /var/www/wordpress/wp-config.php | head -20

# Check NGINX config is valid:
docker exec -it nginx nginx -t

# Check TLS certificate:
openssl s_client -connect mmaarafi.42.fr:443 -tls1_2
```
