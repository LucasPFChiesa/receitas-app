#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

if docker compose version >/dev/null 2>&1; then
    COMPOSE="docker compose"
else
    COMPOSE="docker-compose"
fi

echo "Subindo container de desenvolvimento..."
$COMPOSE up -d --build dev

echo
echo "Status:"
$COMPOSE ps

echo
echo "Desenvolvimento:"
echo "http://localhost:5002"
