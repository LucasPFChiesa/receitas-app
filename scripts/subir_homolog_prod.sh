#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ -f runtime/start.sh ]; then
  exec bash runtime/start.sh --skip-runner --only both "$@"
fi

RUNTIME_DIR="${RUNTIME_DIR:-$HOME/receitas-runtime}"

if [ ! -f "$RUNTIME_DIR/start.sh" ]; then
  echo "Runtime nao encontrado em $RUNTIME_DIR/start.sh." >&2
  echo "Prepare a VM com: bash ~/receitas-runtime/start.sh" >&2
  exit 1
fi

exec bash "$RUNTIME_DIR/start.sh" --skip-runner --only both "$@"
