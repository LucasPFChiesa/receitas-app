#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "Atualizando container de producao..."
sh scripts/docker-compose.sh -f docker-compose.vm.yml --profile prod up -d --build prod

echo "Producao atualizada:"
echo "http://177.44.248.83:5000"
