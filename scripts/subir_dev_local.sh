#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

if docker ps >/dev/null 2>&1; then
    DOCKER="docker"
else
    DOCKER="sudo docker"
fi

if $DOCKER compose version >/dev/null 2>&1; then
    COMPOSE="docker compose"
else
    if [ "$DOCKER" = "sudo docker" ]; then
        COMPOSE="sudo docker-compose"
    else
        COMPOSE="docker-compose"
    fi
fi

echo "Subindo container de desenvolvimento..."
DEV_CONTAINERS="$($DOCKER ps -aq --filter "name=receitas_app_dev")"
if [ -n "$DEV_CONTAINERS" ]; then
    $DOCKER rm -f $DEV_CONTAINERS >/dev/null 2>&1 || true
fi
$COMPOSE up -d --build --remove-orphans dev

echo
echo "Status:"
$COMPOSE ps

echo
echo "Desenvolvimento:"
echo "http://localhost:5002"
