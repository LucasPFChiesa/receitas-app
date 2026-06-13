#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "Derrubando producao..."
sh scripts/docker-compose.sh -f docker-compose.vm.yml --profile prod stop prod
sh scripts/docker-compose.sh -f docker-compose.vm.yml --profile prod rm -f prod
