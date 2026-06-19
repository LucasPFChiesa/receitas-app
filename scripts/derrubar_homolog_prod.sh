#!/usr/bin/env bash
set -euo pipefail

RUNTIME_DIR="${RUNTIME_DIR:-$HOME/receitas-runtime}"

if [ ! -f "$RUNTIME_DIR/docker-compose.yml" ]; then
  echo "Runtime nao encontrado em $RUNTIME_DIR." >&2
  echo "Nada foi derrubado." >&2
  exit 0
fi

cd "$RUNTIME_DIR"

if docker ps >/dev/null 2>&1; then
  if docker compose version >/dev/null 2>&1; then
    docker compose --profile prod down
  else
    docker-compose --profile prod down
  fi
else
  if sudo -n docker compose version >/dev/null 2>&1; then
    sudo docker compose --profile prod down
  else
    sudo docker-compose --profile prod down
  fi
fi
