#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "Subindo ambiente de homologacao..."
sh scripts/docker-compose.sh up -d homolog
sh scripts/docker-compose.sh ps

echo "Homologacao disponivel em:"
echo "http://177.44.248.83:5001"
