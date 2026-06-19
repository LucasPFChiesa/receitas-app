#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f runtime/start.sh ]; then
  echo "runtime/start.sh nao encontrado." >&2
  echo "Na VM sem clone do codigo, use:" >&2
  echo "mkdir -p ~/receitas-runtime" >&2
  echo "curl -fsSL https://raw.githubusercontent.com/LucasPFChiesa/receitas-app/main/runtime/start.sh -o ~/receitas-runtime/start.sh" >&2
  echo "chmod +x ~/receitas-runtime/start.sh" >&2
  echo "bash ~/receitas-runtime/start.sh" >&2
  exit 1
fi

exec bash runtime/start.sh "$@"
