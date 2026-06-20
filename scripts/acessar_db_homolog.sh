#!/usr/bin/env bash
set -euo pipefail

VM_HOST="${VM_HOST:-177.44.248.83}"
VM_USER="${VM_USER:-univates}"
CONTAINER_NAME="receitas_app_homolog"
DB_PATH="/data/receitas_homolog.db"

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  echo "Uso: bash scripts/acessar_db_homolog.sh [SQL]"
  echo "Abre o banco SQLite de homologacao na VM."
  echo
  echo "Exemplos:"
  echo "  bash scripts/acessar_db_homolog.sh"
  echo "  bash scripts/acessar_db_homolog.sh '.tables'"
  echo "  bash scripts/acessar_db_homolog.sh 'SELECT * FROM schema_migrations;'"
  echo
  echo "Para outra VM:"
  echo "  VM_HOST=IP VM_USER=usuario bash scripts/acessar_db_homolog.sh"
  exit 0
fi

if ! command -v ssh >/dev/null 2>&1; then
  echo "Comando obrigatorio nao encontrado: ssh" >&2
  exit 1
fi

REMOTE_SCRIPT="$(cat <<'REMOTE'
set -euo pipefail

docker_cmd() {
  if docker ps >/dev/null 2>&1; then
    docker "$@"
  else
    sudo docker "$@"
  fi
}

DATA_DIR="$(docker_cmd inspect "$CONTAINER_NAME" --format '{{range .Mounts}}{{if eq .Destination "/data"}}{{.Source}}{{end}}{{end}}' 2>/dev/null || true)"

if [ -z "$DATA_DIR" ]; then
  echo "Container $CONTAINER_NAME nao encontrado na VM."
  echo "Suba os ambientes com: bash scripts/iniciar_vm.sh"
  exit 1
fi

DB_FILE="${DATA_DIR}/${DB_PATH#/data/}"

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "sqlite3 nao esta instalado na VM."
  echo "Instale na VM com: sudo apt install -y sqlite3"
  exit 1
fi

if [ -n "${SQL_B64:-}" ]; then
  SQL="$(printf '%s' "$SQL_B64" | base64 -d)"
  sudo sqlite3 "$DB_FILE" "$SQL"
else
  echo "Banco de homologacao:"
  echo "$DB_FILE"
  echo
  exec sudo sqlite3 "$DB_FILE"
fi
REMOTE
)"
printf -v REMOTE_SCRIPT_Q '%q' "$REMOTE_SCRIPT"

if [ "$#" -gt 0 ]; then
  SQL_B64="$(printf '%s' "$*" | base64 -w 0)"
  ssh "${VM_USER}@${VM_HOST}" \
    "CONTAINER_NAME='${CONTAINER_NAME}' DB_PATH='${DB_PATH}' SQL_B64='${SQL_B64}' bash -lc ${REMOTE_SCRIPT_Q}"
else
  ssh -tt "${VM_USER}@${VM_HOST}" \
    "CONTAINER_NAME='${CONTAINER_NAME}' DB_PATH='${DB_PATH}' bash -lc ${REMOTE_SCRIPT_Q}"
fi
