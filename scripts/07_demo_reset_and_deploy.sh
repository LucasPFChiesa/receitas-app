#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "Etapa 1: limpeza completa do Docker."
scripts/clean_docker_images.sh

echo
echo "Etapa 2: checks do projeto."
scripts/02_run_checks.sh

echo
echo "Etapa 3: build da imagem."
docker build -t receitas-app:latest .

echo
echo "Etapa 4: subir homologacao."
scripts/03_deploy_homolog.sh

echo
echo "Etapa 5: subir producao."
scripts/04_deploy_prod.sh

echo
echo "Etapa 6: testar URLs."
scripts/06_test_urls.sh

echo
echo "Demo concluida."
