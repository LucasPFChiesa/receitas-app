#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="receitas_app_prod"
DB_PATH="/data/receitas_prod.db"

docker_cmd() {
  if docker ps >/dev/null 2>&1; then
    docker "$@"
  else
    sudo docker "$@"
  fi
}

open_db() {
  local db_file="$1"

  echo "Banco de producao:"
  echo "$db_file"
  echo

  if command -v sqlite3 >/dev/null 2>&1; then
    sudo sqlite3 "$db_file"
  else
    echo "sqlite3 nao esta instalado nesta maquina."
    echo "Instale com: sudo apt install -y sqlite3"
  fi
}

DATA_DIR="$(docker_cmd inspect "$CONTAINER_NAME" --format '{{range .Mounts}}{{if eq .Destination "/data"}}{{.Source}}{{end}}{{end}}' 2>/dev/null || true)"

if [ -z "$DATA_DIR" ]; then
  echo "Container $CONTAINER_NAME nao encontrado."
  echo "Suba producao com: ./scripts/subir_homolog_prod.sh"
  exit 1
fi

open_db "${DATA_DIR}/${DB_PATH#/data/}"
