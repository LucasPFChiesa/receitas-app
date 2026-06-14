#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "Subindo ambiente de desenvolvimento..."
sh scripts/docker-compose.sh up -d --build dev

echo
echo "Status:"
sh scripts/docker-compose.sh ps

echo
echo "Desenvolvimento:"
echo "http://localhost:5002"
