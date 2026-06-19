#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    echo "Uso: bash scripts/subir_dev_local.sh"
    echo "Sobe o ambiente de desenvolvimento em http://localhost:5002"
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

compose_cmd() {
    if docker ps >/dev/null 2>&1; then
        if docker compose version >/dev/null 2>&1; then
            docker compose "$@"
        else
            docker-compose "$@"
        fi
    elif sudo -n docker ps >/dev/null 2>&1; then
        if sudo -n docker compose version >/dev/null 2>&1; then
            sudo docker compose "$@"
        else
            sudo docker-compose "$@"
        fi
    else
        echo "Sem permissao para acessar Docker. Verifique se o Docker esta rodando e se seu usuario tem permissao." >&2
        exit 1
    fi
}

echo "Subindo container de desenvolvimento..."
DEV_CONTAINERS="$(docker_cmd ps -aq --filter "name=receitas_app_dev")"
if [ -n "$DEV_CONTAINERS" ]; then
    docker_cmd rm -f $DEV_CONTAINERS >/dev/null 2>&1 || true
fi
compose_cmd up -d --build --remove-orphans dev

echo
echo "Status:"
compose_cmd ps

echo
echo "Desenvolvimento:"
echo "http://localhost:5002"
