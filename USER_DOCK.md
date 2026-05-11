# USER_DOC.md — User Documentation

This document explains how to use the Inception stack as an end user or administrator.

---

## What Services Are Provided

The stack runs three services inside Docker containers on a shared private network:

| Service | Description |
|---|---|
| **NGINX** | Reverse proxy and HTTPS entrypoint (port 443, TLSv1.2/1.3) |
| **WordPress + PHP-FPM** | The WordPress CMS with PHP processing (internal port 9000) |
| **MariaDB** | The relational database backend for WordPress (internal port 3306) |

NGINX is the **only** service accessible from outside. WordPress and MariaDB are not directly reachable from the host or internet.

---

## Starting and Stopping the Project

### Start
```bash
make
```
This builds all images and starts all containers in the background.

### Stop (keep data)
```bash
make down
```
Stops and removes containers but keeps volumes (your data is safe).

### Full stop and clean
```bash
make fclean
```
Stops containers, removes images and volumes. **Data will be lost.**

---

## Accessing the Website and Admin Panel

Once the stack is running:

- **WordPress site**: [https://mmaarafi.42.fr](https://mmaarafi.42.fr)
- **WordPress admin panel**: [https://mmaarafi.42.fr/wp-admin](https://mmaarafi.42.fr/wp-admin)

> Your browser will show a warning about the self-signed SSL certificate. Click "Advanced" → "Proceed" to continue.

### Admin credentials

The WordPress administrator account credentials are stored in `secrets/credentials.txt`. Open that file to find the admin username and password.

> The admin username must **not** contain the word "admin" or "administrator" — this is a project requirement.

---

## Locating and Managing Credentials

All credentials are stored in `srcs/.env`. This file is **never committed to Git**.

| Variable | Purpose |
|---|---|
| `WP_ADMIN_USER` | WordPress administrator username |
| `WP_ADMIN_PASSWORD` | WordPress administrator password |
| `WP_USER_LOGIN` | WordPress author username |
| `WP_USER_PASSWORD` | WordPress author password |
| `MYSQL_USER` | MariaDB WordPress user |
| `MYSQL_PASSWORD` | MariaDB WordPress user password |
| `MYSQL_ROOT_PASSWORD` | MariaDB root password |

To change a credential, edit `srcs/.env`, then do a full rebuild:
```bash
make fclean
make
```

---

## Checking That Services Are Running

**Check container status:**
```bash
docker ps
```
All three containers (`nginx`, `wordpress`, `mariadb`) should show `Up` status. If any shows `Restarting`, something is wrong.

**Check logs for a specific service:**
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

**Check MariaDB is working:**
```bash
docker exec -it mariadb mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "SHOW DATABASES;"
```
You should see `wordpress_db` in the list.

**Check WordPress volume has files:**
```bash
docker exec -it wordpress ls /var/www/wordpress
```
You should see WordPress core files like `wp-config.php`, `wp-login.php`, `wp-includes/`, etc.

**Test HTTPS is working:**
```bash
curl -k https://mmaarafi.42.fr
```
You should get HTML back. The `-k` flag bypasses the self-signed cert warning.
