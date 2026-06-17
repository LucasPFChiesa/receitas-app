#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="docker-compose.vm.yml"

if docker ps >/dev/null 2>&1; then
  docker ps -aq --filter "name=receitas_app_homolog" --filter "name=receitas_app_prod" \
    | xargs -r docker rm -f
elif sudo -n docker ps >/dev/null 2>&1; then
  sudo docker ps -aq --filter "name=receitas_app_homolog" --filter "name=receitas_app_prod" \
    | xargs -r sudo docker rm -f
fi

if docker ps >/dev/null 2>&1; then
  if docker compose version >/dev/null 2>&1; then
    docker compose -f "$COMPOSE_FILE" --profile prod up -d --build homolog prod
  else
    docker-compose -f "$COMPOSE_FILE" --profile prod up -d --build homolog prod
  fi
elif sudo -n docker ps >/dev/null 2>&1; then
  if sudo -n docker compose version >/dev/null 2>&1; then
    sudo docker compose -f "$COMPOSE_FILE" --profile prod up -d --build homolog prod
  else
    sudo docker-compose -f "$COMPOSE_FILE" --profile prod up -d --build homolog prod
  fi
else
  echo "Sem permissao para acessar Docker" >&2
  exit 1
fi
