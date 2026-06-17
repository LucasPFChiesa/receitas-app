#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="docker-compose.vm.yml"
APP_IMAGE="${APP_IMAGE:-receitas-app:manual}"
export APP_IMAGE

if ! docker image inspect "$APP_IMAGE" >/dev/null 2>&1 \
  && ! sudo -n docker image inspect "$APP_IMAGE" >/dev/null 2>&1; then
  if [[ "$APP_IMAGE" == receitas-app:manual ]]; then
    if docker ps >/dev/null 2>&1; then
      docker build -t "$APP_IMAGE" .
    else
      sudo docker build -t "$APP_IMAGE" .
    fi
  else
    if docker ps >/dev/null 2>&1; then
      docker pull "$APP_IMAGE"
    else
      sudo docker pull "$APP_IMAGE"
    fi
  fi
fi

if docker ps >/dev/null 2>&1; then
  docker ps -aq --filter "name=receitas_app_homolog" --filter "name=receitas_app_prod" \
    | xargs -r docker rm -f
elif sudo -n docker ps >/dev/null 2>&1; then
  sudo docker ps -aq --filter "name=receitas_app_homolog" --filter "name=receitas_app_prod" \
    | xargs -r sudo docker rm -f
fi

if docker ps >/dev/null 2>&1; then
  if docker compose version >/dev/null 2>&1; then
    docker compose -f "$COMPOSE_FILE" --profile prod up -d homolog prod
  else
    docker-compose -f "$COMPOSE_FILE" --profile prod up -d homolog prod
  fi
elif sudo -n docker ps >/dev/null 2>&1; then
  if sudo -n docker compose version >/dev/null 2>&1; then
    sudo env APP_IMAGE="$APP_IMAGE" docker compose -f "$COMPOSE_FILE" --profile prod up -d homolog prod
  else
    sudo env APP_IMAGE="$APP_IMAGE" docker-compose -f "$COMPOSE_FILE" --profile prod up -d homolog prod
  fi
else
  echo "Sem permissao para acessar Docker" >&2
  exit 1
fi
