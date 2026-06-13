#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "Subindo homologacao..."
sh scripts/docker-compose.sh -f docker-compose.vm.yml up -d --build homolog

echo "Homologacao:"
echo "http://177.44.248.83:5001"
