#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    echo "Uso: bash scripts/derrubar_dev_local.sh"
    echo "Para e remove o container de desenvolvimento local."
    exit 0
fi

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

echo "Derrubando container de desenvolvimento..."
compose_cmd stop dev
compose_cmd rm -f dev

echo
echo "Status:"
compose_cmd ps
