#!/bin/sh
set -e

if docker ps >/dev/null 2>&1; then
    if docker compose version >/dev/null 2>&1; then
        exec docker compose "$@"
    fi

    exec docker-compose "$@"
fi

if sudo -n docker ps >/dev/null 2>&1; then
    if docker compose version >/dev/null 2>&1; then
        exec sudo docker compose "$@"
    fi

    exec sudo docker-compose "$@"
fi

echo "Sem permissao para acessar o Docker. Verifique o grupo docker ou use sudo." >&2
exit 1
