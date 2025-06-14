#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Starting Robust Odoo Database Setup ---"

# Read environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "Error: .env file not found. Please create one."
  exit 1
fi

# Step 1: Clean up any previous Docker containers and volumes for a fresh start.
echo "1. Cleaning up previous Docker containers and volumes..."
docker compose down -v || true


# Step 2: Start ONLY the database service and wait for it to be ready.
echo "2. Starting PostgreSQL database..."
docker compose up -d db # Start only the 'db' service in detached mode

echo "Waiting for PostgreSQL to be ready..."
for i in $(seq 1 60); do # Increased timeout for db readiness
  if docker compose exec db pg_isready -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" &>/dev/null; then
    echo "PostgreSQL is ready."
    break
  fi
  echo -n "."
  sleep 1
done

if ! docker compose exec db pg_isready -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" &>/dev/null; then
  echo "Error: PostgreSQL did not become ready in time. Check 'docker compose logs db'."
  exit 1
fi

# Add a small, fixed delay here for schema creation from an external application like Odoo.
echo "Giving PostgreSQL an extra moment..."
sleep 15 # Increased wait time


# Step 3: Run a temporary Odoo container to create and initialize the database.
# IMPORTANT: Initialize with 'base' first to ensure core tables are created.
# Then, a separate step to install other modules if needed.
echo "3. Creating and initializing Odoo database '${POSTGRES_DB}' with base module..."
docker compose run --rm   -e PGDATABASE="${POSTGRES_DB}"  -e PGUSER="${POSTGRES_USER}"   -e PGPASSWORD="${POSTGRES_PASSWORD}"  -e PGHOST="db"  web  odoo -c /etc/odoo/odoo.conf --database="${POSTGRES_DB}" --init=base --stop-after-init --without-demo=all

echo "Base database initialization command executed. Please review its logs carefully for any errors."

# Optional: If you have custom modules or want to install more after 'base'
# This step is crucial if '--init=all' failed before.
# If you have specific modules you want to install beyond 'base', list them here.
# For example: --init=sale,account,your_custom_module
# echo "3b. Installing additional Odoo modules (if any)..."
# docker compose run --rm \
#   -e PGDATABASE="${POSTGRES_DB}" \
#   -e PGUSER="${POSTGRES_USER}" \
#   -e PGPASSWORD="${POSTGRES_PASSWORD}" \
#   -e PGHOST="db" \
#   web \
#   odoo -c /etc/odoo/odoo.conf --database="${POSTGRES_DB}" --init=sale,account --stop-after-init --without-demo=all
# echo "Additional module installation complete."


echo "--- Starting Odoo for Normal Operation ---"

# Step 4: Start Odoo and PostgreSQL for normal, detached operation.
docker compose up -d

echo "4. Odoo is now running in the background."
echo "You can access Odoo at http://localhost:${ODEV_PORT} (check your .env file for the port)."
echo "To view Odoo and PostgreSQL logs: docker compose logs -f"
echo "To stop Odoo: docker compose down"

echo "Setup Complete!"