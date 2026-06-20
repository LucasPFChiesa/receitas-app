#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="receitas_app_dev"
DB_PATH="/data/receitas_dev.db"

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  echo "Uso: bash scripts/acessar_db_dev.sh [SQL]"
  echo "Abre o banco SQLite de desenvolvimento local pelo container dev."
  echo
  echo "Exemplos:"
  echo "  bash scripts/acessar_db_dev.sh"
  echo "  bash scripts/acessar_db_dev.sh '.tables'"
  echo "  bash scripts/acessar_db_dev.sh '.schema categoria'"
  echo "  bash scripts/acessar_db_dev.sh 'SELECT * FROM schema_migrations;'"
  exit 0
fi

docker_cmd() {
  if docker ps >/dev/null 2>&1; then
    docker "$@"
  elif sudo -n docker ps >/dev/null 2>&1; then
    sudo docker "$@"
  else
    echo "Sem permissao para acessar Docker. Verifique se o Docker esta rodando e se seu usuario tem permissao." >&2
    exit 1
  fi
}

CONTAINER_ID="$(docker_cmd ps -aq --filter "name=$CONTAINER_NAME" | head -n 1)"

if [ -z "$CONTAINER_ID" ]; then
  echo "Container $CONTAINER_NAME nao encontrado."
  echo "Suba o desenvolvimento com: bash scripts/subir_dev_local.sh"
  exit 1
fi

if [ "$#" -gt 0 ]; then
  SQL="$*"
  SQL_B64="$(printf '%s' "$SQL" | base64 -w 0)"
  docker_cmd exec -i "$CONTAINER_ID" python - "$DB_PATH" "$SQL_B64" <<'PY'
import base64
import sqlite3
import sys

db_path = sys.argv[1]
sql = base64.b64decode(sys.argv[2]).decode()
sql_stripped = sql.strip()
params = ()

if sql_stripped == ".tables":
    sql_to_run = "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name"
elif sql_stripped.startswith(".schema"):
    parts = sql_stripped.split(maxsplit=1)
    if len(parts) == 1:
        sql_to_run = "SELECT sql FROM sqlite_master WHERE sql IS NOT NULL ORDER BY name"
        params = ()
    else:
        sql_to_run = "SELECT sql FROM sqlite_master WHERE name = ? AND sql IS NOT NULL"
        params = (parts[1],)
else:
    sql_to_run = sql
    params = ()

conn = sqlite3.connect(db_path)
try:
    rows = conn.execute(sql_to_run, params).fetchall()
    for row in rows:
        print("|".join(str(value) for value in row))
finally:
    conn.close()
PY
else
  echo "Banco de desenvolvimento dentro do container:"
  echo "$DB_PATH"
  echo
  echo "Modo SQL interativo. Exemplos: SELECT name FROM sqlite_master WHERE type = 'table';"
  docker_cmd exec -it "$CONTAINER_ID" python -m sqlite3 "$DB_PATH"
fi
