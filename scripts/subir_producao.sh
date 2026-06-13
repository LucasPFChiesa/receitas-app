#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "Subindo producao..."
sh scripts/docker-compose.sh -f docker-compose.vm.yml --profile prod up -d --build prod

echo "Producao:"
echo "http://177.44.248.83:5000"
