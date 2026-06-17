#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
APP_DIR="$(pwd)"

ask() {
  local label="$1"
  local default_value="$2"
  local value

  if [ -n "$default_value" ]; then
    read -r -p "$label [$default_value]: " value
    echo "${value:-$default_value}"
  else
    read -r -p "$label: " value
    echo "$value"
  fi
}

ask_secret() {
  local label="$1"
  local value

  read -r -s -p "$label: " value
  echo >&2
  echo "$value"
}

echo "Preparacao completa da VM para receitas-app"
echo

REPO_OWNER="$(ask "Dono do repositorio" "${REPO_OWNER:-LucasPFChiesa}")"
REPO_NAME="$(ask "Nome do repositorio" "${REPO_NAME:-receitas-app}")"
RUNNER_NAME="$(ask "Nome do runner" "${RUNNER_NAME:-receitas-app-vm}")"
RUNNER_LABELS="$(ask "Labels do runner" "${RUNNER_LABELS:-receitas-app-vm,homologacao,producao}")"
RUNNER_DIR="$(ask "Pasta de instalacao do runner" "${RUNNER_DIR:-$HOME/actions-runner}")"
TOKEN_FILE="$(ask "Arquivo do token GitHub" "${TOKEN_FILE:-$HOME/keys/github_token.txt}")"
PUBLIC_HOST="$(ask "IP ou host publico da VM" "${PUBLIC_HOST:-177.44.248.83}")"
APP_IMAGE="${APP_IMAGE:-receitas-app:manual}"

if [ ! -f "$TOKEN_FILE" ]; then
  echo
  echo "Token nao encontrado em $TOKEN_FILE."
  echo "Cole um token do GitHub com permissao para administrar Actions runners deste repositorio."
  GITHUB_TOKEN="$(ask_secret "GitHub token")"
  mkdir -p "$(dirname "$TOKEN_FILE")"
  printf "%s\n" "$GITHUB_TOKEN" > "$TOKEN_FILE"
  chmod 600 "$TOKEN_FILE"
else
  GITHUB_TOKEN="$(tr -d "\r\n" < "$TOKEN_FILE")"
fi

if [ -z "$GITHUB_TOKEN" ]; then
  echo "Token vazio. Nao foi possivel configurar o runner." >&2
  exit 1
fi

REPO_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}"

echo
echo "Instalando dependencias da VM..."
sudo apt-get update
sudo apt-get install -y curl tar git python3 docker.io docker-compose
sudo systemctl enable --now docker

echo
echo "Obtendo token temporario de registro do runner..."
REGISTRATION_TOKEN="$(
  curl -fsSL \
    -X POST \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runners/registration-token" \
    | python3 -c "import json,sys; print(json.load(sys.stdin)['token'])"
)"

if [ -d "$RUNNER_DIR" ]; then
  echo
  echo "Runner anterior encontrado em $RUNNER_DIR. Removendo instalacao local..."
  cd "$RUNNER_DIR"

  if [ -f ./svc.sh ]; then
    sudo ./svc.sh stop || true
    sudo ./svc.sh uninstall || true
  fi

  if [ -f .runner ]; then
    REMOVE_TOKEN="$(
      curl -fsSL \
        -X POST \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runners/remove-token" \
        | python3 -c "import json,sys; print(json.load(sys.stdin)['token'])"
    )"
    ./config.sh remove --token "$REMOVE_TOKEN" || true
  fi

  cd "$HOME"
  rm -rf "$RUNNER_DIR"
  cd "$APP_DIR"
fi

echo
echo "Baixando GitHub Actions runner mais recente..."
mkdir -p "$RUNNER_DIR"
cd "$RUNNER_DIR"

RUNNER_VERSION="$(
  curl -fsSL https://api.github.com/repos/actions/runner/releases/latest \
    | python3 -c "import json,sys; print(json.load(sys.stdin)['tag_name'].lstrip('v'))"
)"
RUNNER_PACKAGE="actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"

curl -fsSLO "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_PACKAGE}"
tar xzf "$RUNNER_PACKAGE"

echo
echo "Configurando runner ${RUNNER_NAME} em ${REPO_URL}..."
./config.sh \
  --unattended \
  --url "$REPO_URL" \
  --token "$REGISTRATION_TOKEN" \
  --name "$RUNNER_NAME" \
  --labels "$RUNNER_LABELS" \
  --replace

echo
echo "Instalando runner como servico..."
sudo ./svc.sh install
sudo ./svc.sh start
sudo ./svc.sh status || true

cd "$APP_DIR"

echo
echo "Subindo homologacao e producao..."
APP_IMAGE="$APP_IMAGE" ./scripts/subir_homolog_prod.sh

echo
echo "Ambientes prontos:"
echo "Homologacao: http://${PUBLIC_HOST}:5001"
echo "Producao:    http://${PUBLIC_HOST}:5000"
echo
echo "Runner pronto no GitHub com labels: ${RUNNER_LABELS}"
