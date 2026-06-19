#!/usr/bin/env bash
set -euo pipefail

RUNTIME_DIR="${RUNTIME_DIR:-$HOME/receitas-runtime}"
START_URL="${START_URL:-https://raw.githubusercontent.com/LucasPFChiesa/receitas-app/main/runtime/start.sh}"

echo "Recriando runtime da VM para apresentacao"
echo

echo "Removendo containers antigos..."
sudo docker rm -f receitas_app_homolog receitas_app_prod 2>/dev/null || true

echo "Preparando pasta runtime..."
mkdir -p "$RUNTIME_DIR"

echo "Baixando start.sh runtime..."
curl -fsSL "$START_URL" -o "$RUNTIME_DIR/start.sh"
chmod +x "$RUNTIME_DIR/start.sh"

echo
echo "Executando runtime/start.sh..."
exec bash "$RUNTIME_DIR/start.sh"
