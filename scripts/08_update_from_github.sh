#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "Atualizando projeto pelo GitHub..."
git pull

echo "Arquivos principais esperados:"
ls -1 Dockerfile Jenkinsfile docker-compose.yml docker-entrypoint.sh requirements-dev.txt scripts/docker-compose.sh

echo "Projeto atualizado."
