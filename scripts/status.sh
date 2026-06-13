#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "Containers:"
sh scripts/docker-compose.sh -f docker-compose.vm.yml --profile prod ps

echo
echo "URLs:"
echo "Homologacao: http://177.44.248.83:5001"
echo "Producao:    http://177.44.248.83:5000"
echo "Integracao:  https://github.com/LucasPFChiesa/receitas-app/actions"
