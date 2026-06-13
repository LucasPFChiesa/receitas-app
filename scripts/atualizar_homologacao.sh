#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "Atualizando container de homologacao..."
sh scripts/docker-compose.sh -f docker-compose.vm.yml up -d --build homolog

echo "Homologacao atualizada:"
echo "http://177.44.248.83:5001"
