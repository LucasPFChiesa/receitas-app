#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

VM_HOST="${1:-${VM_HOST:-177.44.248.83}}"
VM_USER="${2:-${VM_USER:-univates}}"
RUNTIME_DIR="${RUNTIME_DIR:-/home/${VM_USER}/receitas-runtime}"

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  echo "Uso: bash scripts/enviar_vm.sh [VM_HOST] [VM_USER]"
  echo "Envia runtime/start.sh para a pasta runtime da VM."
  exit 0
fi

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Comando obrigatorio nao encontrado: $1" >&2
    exit 1
  fi
}

require_command ssh
require_command scp

if [ ! -f runtime/start.sh ]; then
  echo "Arquivo runtime/start.sh nao encontrado." >&2
  exit 1
fi

echo "Criando pasta runtime na VM..."
ssh "${VM_USER}@${VM_HOST}" "mkdir -p '${RUNTIME_DIR}'"

echo "Enviando runtime/start.sh para a VM..."
scp runtime/start.sh "${VM_USER}@${VM_HOST}:${RUNTIME_DIR}/start.sh"

echo "Ajustando permissao de execucao..."
ssh "${VM_USER}@${VM_HOST}" "chmod +x '${RUNTIME_DIR}/start.sh'"

echo
echo "Runtime enviado para ${VM_USER}@${VM_HOST}:${RUNTIME_DIR}"
