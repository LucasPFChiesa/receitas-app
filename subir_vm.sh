#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="docker-compose.vm.yml"

if docker compose version >/dev/null 2>&1; then
  docker compose -f "$COMPOSE_FILE" --profile prod up -d --build homolog prod
elif command -v docker-compose >/dev/null 2>&1; then
  docker-compose -f "$COMPOSE_FILE" --profile prod up -d --build homolog prod
elif sudo -n docker compose version >/dev/null 2>&1; then
  sudo docker compose -f "$COMPOSE_FILE" --profile prod up -d --build homolog prod
else
  sudo docker-compose -f "$COMPOSE_FILE" --profile prod up -d --build homolog prod
fi
