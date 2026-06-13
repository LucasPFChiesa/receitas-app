#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "Subindo container de desenvolvimento..."
sh scripts/docker-compose.sh up -d dev
sh scripts/docker-compose.sh ps

echo "Ambiente de desenvolvimento:"
echo "http://localhost:5002"
echo
echo "Edite os arquivos no seu PC normalmente. O container usa volume .:/app."
