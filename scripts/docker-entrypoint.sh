#!/bin/sh
set -e

DB_DIR="$(dirname "$DATABASE_PATH")"
mkdir -p "$DB_DIR"

python init_db.py

exec "$@"
