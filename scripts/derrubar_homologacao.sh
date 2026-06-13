#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "Derrubando homologacao..."
sh scripts/docker-compose.sh -f docker-compose.vm.yml stop homolog
sh scripts/docker-compose.sh -f docker-compose.vm.yml rm -f homolog
