# Odoo 18 Docker Setup

## Overview

This project provides a reproducible, script-driven setup for Odoo 18 and PostgreSQL using Docker Compose.
Configuration is controlled via `.env` and `odoo.conf`.

---

## Files

* **compose.yml** – Docker Compose definition (Odoo + Postgres, persistent volumes, variable substitution).
* **setup.sh** – Idempotent setup script for database initialisation and service orchestration.
* **.env** – Environment variables (Postgres user, password, db, Odoo port).
* **odoo.conf** – Odoo server configuration.
* **addons/** – Local Odoo addons directory (mounted in container).

---

## Requirements

* Docker
* Docker Compose plugin (`docker compose`)
* Bash shell

---

## Quick Start

1. **Edit `.env`**
   Set your Postgres/Odoo details:

   ```
   POSTGRES_USER=odoo_dev
   POSTGRES_PASSWORD=yourpassword
   POSTGRES_DB=custom_odoo_db_1
   ODEV_PORT=8018
   ```

2. **Edit `odoo.conf` as needed**
   Ensure port and paths align with `.env` and volumes.

3. **Run setup**

   ```
   ./setup.sh
   ```

4. **Access Odoo**
   Open [http://localhost:8018](http://localhost:8018) (or your configured port).

---

## Script Logic (`setup.sh`)

* Loads `.env` variables
* Brings down and cleans previous Docker containers/volumes
* Starts only the database, waits for readiness
* Runs Odoo initialisation (`--init=base`) in an isolated step
* Brings up full stack in detached mode

---

## Useful Commands

* **View logs**:
  `docker compose logs -f`

* **Stop services**:
  `docker compose down`

---

## Notes

* `.env` values must have no spaces before or after `=`.
* Only Odoo 18 and PostgreSQL 17 tested.
* All data is persisted via Docker named volumes.

---

## Troubleshooting

* If setup fails:

  * Check `.env` for whitespace or missing variables.
  * Inspect logs: `docker compose logs -f`
  * Review output of `setup.sh` for early errors.

---

## Customisation

* To add Odoo modules:
  Mount them in `addons/` and adjust the setup script’s init command if needed.

---

## Directory Structure

```
.
├── addons/
├── compose.yml
├── odoo.conf
├── setup.sh
└── .env
```

---


# Useful Docker Commands

### start docker services

systemctl start docker

### docker run with logs

docker compose up -d && docker compose logs -f

### docker down 
docker compose down

### docker list 

docker ps -as

### delete all docker instances

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker system prune
docker system prune --all --volumes
docker volume prune

### docker compose logs 

docker compose logs -f