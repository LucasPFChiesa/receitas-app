#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

COPY_TOKEN="no"
COPY_TOKEN_IF_MISSING="no"
POSITIONAL=()

usage() {
  cat <<'EOF'
Uso:
  bash scripts/enviar_vm.sh [opcoes] [VM_HOST] [VM_USER]

Opcoes:
  --token              envia ~/keys/github_token.txt para a VM, sobrescrevendo
  --token-if-missing   envia o token somente se ele nao existir na VM
  -h, --help           mostra esta ajuda

Variaveis opcionais:
  VM_HOST              host/IP da VM
  VM_USER              usuario SSH da VM
  RUNTIME_DIR          pasta runtime na VM
  LOCAL_TOKEN_FILE     token local, padrao: ~/keys/github_token.txt
  REMOTE_TOKEN_FILE    token na VM, padrao: /home/VM_USER/keys/github_token.txt
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --token|--with-token)
      COPY_TOKEN="yes"
      ;;
    --token-if-missing)
      COPY_TOKEN_IF_MISSING="yes"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      POSITIONAL+=("$1")
      ;;
  esac
  shift
done

VM_HOST="${POSITIONAL[0]:-${VM_HOST:-177.44.248.83}}"
VM_USER="${POSITIONAL[1]:-${VM_USER:-univates}}"
RUNTIME_DIR="${RUNTIME_DIR:-/home/${VM_USER}/receitas-runtime}"
LOCAL_TOKEN_FILE="${LOCAL_TOKEN_FILE:-$HOME/keys/github_token.txt}"
REMOTE_TOKEN_FILE="${REMOTE_TOKEN_FILE:-/home/${VM_USER}/keys/github_token.txt}"

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

copy_token_to_vm() {
  local remote_key_dir
  remote_key_dir="$(dirname "$REMOTE_TOKEN_FILE")"

  if [ ! -f "$LOCAL_TOKEN_FILE" ]; then
    echo "Token local nao encontrado: $LOCAL_TOKEN_FILE" >&2
    echo "Crie esse arquivo ou informe outro com LOCAL_TOKEN_FILE=/caminho/token." >&2
    exit 1
  fi

  echo "Criando pasta de tokens na VM..."
  ssh "${VM_USER}@${VM_HOST}" "mkdir -p '${remote_key_dir}' && chmod 700 '${remote_key_dir}'"

  echo "Enviando token GitHub para a VM..."
  scp "$LOCAL_TOKEN_FILE" "${VM_USER}@${VM_HOST}:${REMOTE_TOKEN_FILE}"
  ssh "${VM_USER}@${VM_HOST}" "chmod 600 '${REMOTE_TOKEN_FILE}'"
}

echo "Criando pasta runtime na VM..."
ssh "${VM_USER}@${VM_HOST}" "mkdir -p '${RUNTIME_DIR}'"

echo "Enviando runtime/start.sh para a VM..."
scp runtime/start.sh "${VM_USER}@${VM_HOST}:${RUNTIME_DIR}/start.sh"

echo "Ajustando permissao de execucao..."
ssh "${VM_USER}@${VM_HOST}" "chmod +x '${RUNTIME_DIR}/start.sh'"

if [ "$COPY_TOKEN_IF_MISSING" = "yes" ]; then
  if ssh "${VM_USER}@${VM_HOST}" "test -s '${REMOTE_TOKEN_FILE}'"; then
    echo "Token GitHub ja existe na VM em ${REMOTE_TOKEN_FILE}. Nao copiei."
  else
    copy_token_to_vm
  fi
elif [ "$COPY_TOKEN" = "yes" ]; then
  copy_token_to_vm
fi

echo
echo "Runtime enviado para ${VM_USER}@${VM_HOST}:${RUNTIME_DIR}"
