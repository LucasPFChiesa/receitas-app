#!/usr/bin/env bash
set -euo pipefail

VM_HOST="${1:-${VM_HOST:-177.44.248.83}}"
VM_USER="${2:-${VM_USER:-univates}}"
RUNTIME_DIR="${RUNTIME_DIR:-/home/${VM_USER}/receitas-runtime}"
RUNNER_DIR="${RUNNER_DIR:-/home/${VM_USER}/actions-runner}"
RUNNER_SERVICE="${RUNNER_SERVICE:-actions.runner.LucasPFChiesa-receitas-app.receitas-app-vm.service}"
IMAGE_REPOSITORY="${IMAGE_REPOSITORY:-ghcr.io/lucaspfchiesa/receitas-app}"
REPO_OWNER="${REPO_OWNER:-LucasPFChiesa}"
REPO_NAME="${REPO_NAME:-receitas-app}"
TOKEN_FILE="${TOKEN_FILE:-/home/${VM_USER}/keys/github_token.txt}"

if ! command -v ssh >/dev/null 2>&1; then
  echo "Comando obrigatorio nao encontrado: ssh" >&2
  exit 1
fi

ssh "${VM_USER}@${VM_HOST}" \
  "RUNTIME_DIR='${RUNTIME_DIR}' RUNNER_DIR='${RUNNER_DIR}' RUNNER_SERVICE='${RUNNER_SERVICE}' IMAGE_REPOSITORY='${IMAGE_REPOSITORY}' REPO_OWNER='${REPO_OWNER}' REPO_NAME='${REPO_NAME}' TOKEN_FILE='${TOKEN_FILE}' bash -s" <<'REMOTE'
set -euo pipefail

docker_cmd() {
  if docker ps >/dev/null 2>&1; then
    docker "$@"
  else
    sudo docker "$@"
  fi
}

echo "Limpando runtime da aplicacao na VM..."

if [ -d "$RUNNER_DIR" ]; then
  echo "Removendo runner..."
  cd "$RUNNER_DIR"
  if [ -f ./svc.sh ]; then
    sudo ./svc.sh stop || true
    sudo ./svc.sh uninstall || true
  else
    sudo systemctl stop "$RUNNER_SERVICE" 2>/dev/null || true
    sudo systemctl disable "$RUNNER_SERVICE" 2>/dev/null || true
  fi

  if [ -f .runner ] && [ -f "$TOKEN_FILE" ]; then
    GITHUB_TOKEN="$(tr -d '\r\n' < "$TOKEN_FILE")"
    if [ -n "$GITHUB_TOKEN" ]; then
      REMOVE_TOKEN="$(
        curl -fsSL \
          -X POST \
          -H "Authorization: Bearer ${GITHUB_TOKEN}" \
          -H "Accept: application/vnd.github+json" \
          "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runners/remove-token" \
          | python3 -c "import json,sys; print(json.load(sys.stdin)['token'])"
      )" || REMOVE_TOKEN=""
      if [ -n "${REMOVE_TOKEN:-}" ]; then
        ./config.sh remove --token "$REMOVE_TOKEN" || true
      fi
    fi
  fi

  cd "$HOME"
  rm -rf "$RUNNER_DIR"
fi

echo "Removendo containers e volumes da aplicacao..."
docker_cmd rm -f receitas_app_homolog receitas_app_prod 2>/dev/null || true
docker_cmd volume rm \
  receitas-app_homolog_data \
  receitas-app_prod_data \
  receitas_app_homolog_data \
  receitas_app_prod_data \
  homolog_data \
  prod_data \
  2>/dev/null || true

echo "Removendo imagens antigas da aplicacao..."
docker_cmd images "$IMAGE_REPOSITORY" --format '{{.Repository}}:{{.Tag}}' \
  | while read -r image; do
      [ -z "$image" ] && continue
      docker_cmd rmi -f "$image" || true
    done

echo "Removendo pastas runtime/clone antigo..."
rm -rf "$RUNTIME_DIR" "$HOME/receitas-app"

echo "Limpando cache Docker nao usado..."
docker_cmd system prune -af || true

echo
echo "VM limpa para uma nova demonstracao."
REMOTE
