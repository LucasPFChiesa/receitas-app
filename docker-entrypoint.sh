#!/bin/sh
set -e

DB_DIR="$(dirname "$DATABASE_PATH")"
mkdir -p "$DB_DIR"

if [ ! -f "$DATABASE_PATH" ]; then
    python init_db.py
fi

exec "$@"
