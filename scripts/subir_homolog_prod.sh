#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

COMPOSE_FILE="docker-compose.vm.yml"
APP_IMAGE="${APP_IMAGE:-receitas-app:manual}"
export APP_IMAGE

docker_cmd() {
  if docker ps >/dev/null 2>&1; then
    docker "$@"
  else
    sudo docker "$@"
  fi
}

compose_cmd() {
  if docker ps >/dev/null 2>&1; then
    if docker compose version >/dev/null 2>&1; then
      docker compose "$@"
    else
      docker-compose "$@"
    fi
  else
    if sudo -n docker compose version >/dev/null 2>&1; then
      sudo env APP_IMAGE="$APP_IMAGE" docker compose "$@"
    else
      sudo env APP_IMAGE="$APP_IMAGE" docker-compose "$@"
    fi
  fi
}

if ! docker_cmd image inspect "$APP_IMAGE" >/dev/null 2>&1; then
  if [[ "$APP_IMAGE" == receitas-app:manual ]]; then
    docker_cmd build -t "$APP_IMAGE" .
  else
    docker_cmd pull "$APP_IMAGE"
  fi
fi

CONTAINERS="$(docker_cmd ps -aq --filter "name=receitas_app_homolog" --filter "name=receitas_app_prod")"
if [ -n "$CONTAINERS" ]; then
  docker_cmd rm -f $CONTAINERS
fi

compose_cmd -f "$COMPOSE_FILE" --profile prod up -d homolog prod

echo
echo "Homologacao: http://177.44.248.83:5001"
echo "Producao:    http://177.44.248.83:5000"
