#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/LucasPFChiesa/receitas-app.git}"
BRANCH="${BRANCH:-integracao}"
APP_DIR="${APP_DIR:-$HOME/receitas-app}"
RUNNER_SERVICE="${RUNNER_SERVICE:-actions.runner.LucasPFChiesa-receitas-app.receitas-app-vm.service}"

echo "Recriando VM para apresentacao"
echo

echo "Parando runner se existir..."
sudo systemctl stop "$RUNNER_SERVICE" 2>/dev/null || true

if [ -d "$APP_DIR" ]; then
  echo "Derrubando ambientes pelo clone atual..."
  cd "$APP_DIR"
  if [ -x scripts/derrubar_homolog_prod.sh ]; then
    bash scripts/derrubar_homolog_prod.sh || true
  fi
fi

echo "Removendo containers antigos..."
sudo docker rm -f receitas_app_homolog receitas_app_prod 2>/dev/null || true

if [ -d "$APP_DIR" ] && [ -x "$APP_DIR/scripts/clean_docker_images.sh" ]; then
  echo "Limpando imagens antigas pelo script do projeto..."
  cd "$APP_DIR"
  bash scripts/clean_docker_images.sh || true
fi

echo "Apagando clone antigo..."
rm -rf "$APP_DIR"

echo "Clonando repositorio..."
git clone --branch "$BRANCH" "$REPO_URL" "$APP_DIR"

cd "$APP_DIR"

echo
echo "Executando start.sh do clone novo..."
exec bash scripts/start.sh
