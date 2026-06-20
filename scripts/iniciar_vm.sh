#!/usr/bin/env bash
set -euo pipefail

VM_HOST="${1:-${VM_HOST:-177.44.248.83}}"
VM_USER="${2:-${VM_USER:-univates}}"
RUNTIME_DIR="${RUNTIME_DIR:-/home/${VM_USER}/receitas-runtime}"
APP_IMAGE_VALUE="${APP_IMAGE:-}"

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  echo "Uso: bash scripts/iniciar_vm.sh [VM_HOST] [VM_USER] [APP_IMAGE]"
  echo "Recria/configura runner e sobe homologacao e producao na VM."
  echo
  echo "Exemplo com imagem especifica:"
  echo "  bash scripts/iniciar_vm.sh 177.44.248.83 univates ghcr.io/lucaspfchiesa/receitas-app:SHA"
  exit 0
fi

if ! command -v ssh >/dev/null 2>&1; then
  echo "Comando obrigatorio nao encontrado: ssh" >&2
  exit 1
fi

if [ "$#" -ge 3 ]; then
  APP_IMAGE_VALUE="$3"
fi

REMOTE_CHECK="test -x '${RUNTIME_DIR}/start.sh' || { echo 'Runtime nao encontrado. Rode primeiro: bash scripts/enviar_vm.sh' >&2; exit 1; }"

if [ -n "$APP_IMAGE_VALUE" ]; then
  ssh "${VM_USER}@${VM_HOST}" \
    "${REMOTE_CHECK}; bash '${RUNTIME_DIR}/start.sh' --non-interactive --image '${APP_IMAGE_VALUE}' --only both --runtime-dir '${RUNTIME_DIR}'"
else
  ssh "${VM_USER}@${VM_HOST}" \
    "${REMOTE_CHECK}; bash '${RUNTIME_DIR}/start.sh' --non-interactive --only both --runtime-dir '${RUNTIME_DIR}'"
fi
