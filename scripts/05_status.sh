#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "Status dos containers do projeto:"
sh scripts/docker-compose.sh ps

echo
echo "Imagens Docker do receitas-app:"
docker images "receitas-app"

echo
echo "Portas esperadas:"
echo "Jenkins      http://177.44.248.83:8080"
echo "Homologacao  http://177.44.248.83:5001"
echo "Producao     http://177.44.248.83:5000"
