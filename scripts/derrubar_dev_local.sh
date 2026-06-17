#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

if docker compose version >/dev/null 2>&1; then
    COMPOSE="docker compose"
else
    COMPOSE="docker-compose"
fi

echo "Derrubando container de desenvolvimento..."
$COMPOSE stop dev
$COMPOSE rm -f dev

echo
echo "Status:"
$COMPOSE ps
