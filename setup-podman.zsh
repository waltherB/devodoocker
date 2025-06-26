#!/bin/zsh
set -e

# Load .env variables
if [[ -f .env ]]; then
    set -a
    source .env
    set +a
else
    echo "Error: .env file not found."
    exit 1
fi

# Check required environment variables
: "${POSTGRES_DB:?POSTGRES_DB not set}"
: "${POSTGRES_USER:?POSTGRES_USER not set}"
: "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD not set}"

# Clean up any old containers (optional)
# podman-compose down -v || true

# 1. Start DB (and web, but web will restart if DB not ready)
podman-compose up -d --remove-orphans db

# 2. Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
for i in {1..60}; do
    if podman-compose exec db pg_isready -U "${POSTGRES_USER}" &>/dev/null; then
        echo "PostgreSQL is ready."
        break
    fi
    echo -n "."
    sleep 1
done

if ! podman-compose exec db pg_isready -U "${POSTGRES_USER}" &>/dev/null; then
    echo "Error: PostgreSQL did not become ready in time."
    exit 1
fi

# 3. Ensure the DB exists (works even if already present)
echo "Ensuring PostgreSQL database '${POSTGRES_DB}' exists..."
podman-compose exec db psql -U "${POSTGRES_USER}" -tc "SELECT 1 FROM pg_database WHERE datname = '${POSTGRES_DB}';" | grep -q 1 || \
  podman-compose exec db createdb -U "${POSTGRES_USER}" "${POSTGRES_DB}"

# 4. Initialise Odoo base module
podman-compose run --rm web \
  odoo -c /etc/odoo/odoo.conf -d "${POSTGRES_DB}" -i base --stop-after-init

echo "Base module initialised. Now starting Odoo in normal mode..."
podman-compose up -d --remove-orphans
