#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "Subindo ambiente de producao..."
sh scripts/docker-compose.sh --profile prod up -d prod
sh scripts/docker-compose.sh ps

echo "Producao disponivel em:"
echo "http://177.44.248.83:5000"
