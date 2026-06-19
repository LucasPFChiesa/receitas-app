#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="${REPO_OWNER:-LucasPFChiesa}"
REPO_NAME="${REPO_NAME:-receitas-app}"
IMAGE_REPOSITORY="${IMAGE_REPOSITORY:-ghcr.io/lucaspfchiesa/receitas-app}"
RUNTIME_DIR="${RUNTIME_DIR:-$HOME/receitas-runtime}"
RUNNER_DIR="${RUNNER_DIR:-$HOME/actions-runner}"
RUNNER_NAME="${RUNNER_NAME:-receitas-app-vm}"
RUNNER_LABELS="${RUNNER_LABELS:-receitas-app-vm,homologacao,producao}"
TOKEN_FILE="${TOKEN_FILE:-$HOME/keys/github_token.txt}"
PUBLIC_HOST="${PUBLIC_HOST:-177.44.248.83}"
DEPLOY_TARGET="both"
APP_IMAGE="${APP_IMAGE:-}"
NON_INTERACTIVE="no"
CONFIGURE_RUNNER="yes"
INSTALL_DEPS="yes"
CLEAN_BEFORE_UP="yes"

usage() {
  cat <<'EOF'
Uso:
  bash start.sh [opcoes]

Opcoes:
  --non-interactive       usa valores padrao, sem perguntas
  --skip-runner           nao instala/reconfigura o self-hosted runner
  --skip-deps             nao instala pacotes apt
  --image IMAGEM          imagem Docker para subir
  --only homolog|prod|both
  --runtime-dir DIR
  --public-host HOST
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --non-interactive) NON_INTERACTIVE="yes" ;;
    --skip-runner) CONFIGURE_RUNNER="no" ;;
    --skip-deps) INSTALL_DEPS="no" ;;
    --image) APP_IMAGE="$2"; shift ;;
    --only) DEPLOY_TARGET="$2"; shift ;;
    --runtime-dir) RUNTIME_DIR="$2"; shift ;;
    --public-host) PUBLIC_HOST="$2"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Opcao desconhecida: $1" >&2; usage; exit 1 ;;
  esac
  shift
done

ask() {
  local label="$1"
  local default_value="$2"
  local value

  if [ "$NON_INTERACTIVE" = "yes" ]; then
    echo "$default_value"
    return
  fi

  read -r -p "$label [$default_value]: " value
  echo "${value:-$default_value}"
}

ask_yes_no() {
  local label="$1"
  local default_value="$2"
  local value

  if [ "$NON_INTERACTIVE" = "yes" ]; then
    value="$default_value"
  else
    read -r -p "$label [$default_value]: " value
    value="${value:-$default_value}"
  fi

  case "$value" in
    s|S|sim|SIM|y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

ask_secret() {
  local label="$1"
  local value

  read -r -s -p "$label: " value
  echo >&2
  echo "$value"
}

docker_cmd() {
  if docker ps >/dev/null 2>&1; then
    docker "$@"
  else
    sudo docker "$@"
  fi
}

compose_cmd() {
  if docker ps >/dev/null 2>&1; then
    if docker compose version >/dev/null 2>&1; then
      docker compose "$@"
    else
      docker-compose "$@"
    fi
  else
    if sudo -n docker compose version >/dev/null 2>&1; then
      sudo env APP_IMAGE="$APP_IMAGE" COMPOSE_PROJECT_NAME=receitas-app docker compose "$@"
    else
      sudo env APP_IMAGE="$APP_IMAGE" COMPOSE_PROJECT_NAME=receitas-app docker-compose "$@"
    fi
  fi
}

write_compose() {
  mkdir -p "$RUNTIME_DIR"
  cat > "$RUNTIME_DIR/docker-compose.yml" <<'YAML'
services:
  homolog:
    image: ${APP_IMAGE}
    container_name: receitas_app_homolog
    restart: unless-stopped
    environment:
      FLASK_ENV: homolog
      DATABASE_PATH: /data/receitas_homolog.db
    ports:
      - "5001:5000"
    volumes:
      - homolog_data:/data

  prod:
    image: ${APP_IMAGE}
    container_name: receitas_app_prod
    restart: unless-stopped
    environment:
      FLASK_ENV: production
      DATABASE_PATH: /data/receitas_prod.db
    ports:
      - "5000:5000"
    volumes:
      - prod_data:/data
    profiles:
      - prod

volumes:
  homolog_data:
  prod_data:
YAML
}

load_token() {
  if [ ! -f "$TOKEN_FILE" ]; then
    if [ "$NON_INTERACTIVE" = "yes" ]; then
      echo "Token nao encontrado em $TOKEN_FILE" >&2
      exit 1
    fi
    echo
    echo "Token nao encontrado em $TOKEN_FILE."
    echo "Cole um token GitHub com permissao Administration: Read and write."
    GITHUB_TOKEN="$(ask_secret "GitHub token")"
    mkdir -p "$(dirname "$TOKEN_FILE")"
    printf "%s\n" "$GITHUB_TOKEN" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
  else
    GITHUB_TOKEN="$(tr -d "\r\n" < "$TOKEN_FILE")"
  fi

  if [ -z "$GITHUB_TOKEN" ]; then
    echo "Token GitHub vazio." >&2
    exit 1
  fi
}

latest_integracao_image() {
  load_token
  local sha
  sha="$(
    curl -fsSL \
      -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -H "Accept: application/vnd.github+json" \
      "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/branches/integracao" \
      | python3 -c "import json,sys; print(json.load(sys.stdin)['commit']['sha'])"
  )"
  echo "${IMAGE_REPOSITORY}:${sha}"
}

install_deps() {
  if [ "$INSTALL_DEPS" != "yes" ]; then
    return
  fi
  echo
  echo "Instalando dependencias da VM..."
  sudo apt-get update
  sudo apt-get install -y curl tar git python3 docker.io docker-compose
  sudo systemctl enable --now docker
}

configure_runner() {
  if [ "$CONFIGURE_RUNNER" != "yes" ]; then
    return
  fi

  load_token
  local repo_url="https://github.com/${REPO_OWNER}/${REPO_NAME}"
  local registration_token remove_token runner_version runner_package

  echo
  echo "Obtendo token temporario de registro do runner..."
  registration_token="$(
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
      remove_token="$(
        curl -fsSL \
          -X POST \
          -H "Authorization: Bearer ${GITHUB_TOKEN}" \
          -H "Accept: application/vnd.github+json" \
          "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runners/remove-token" \
          | python3 -c "import json,sys; print(json.load(sys.stdin)['token'])"
      )"
      ./config.sh remove --token "$remove_token" || true
    fi
    cd "$HOME"
    rm -rf "$RUNNER_DIR"
  fi

  echo
  echo "Baixando GitHub Actions runner mais recente..."
  mkdir -p "$RUNNER_DIR"
  cd "$RUNNER_DIR"
  runner_version="$(
    curl -fsSL https://api.github.com/repos/actions/runner/releases/latest \
      | python3 -c "import json,sys; print(json.load(sys.stdin)['tag_name'].lstrip('v'))"
  )"
  runner_package="actions-runner-linux-x64-${runner_version}.tar.gz"
  curl -fsSLO "https://github.com/actions/runner/releases/download/v${runner_version}/${runner_package}"
  tar xzf "$runner_package"

  echo
  echo "Configurando runner ${RUNNER_NAME} em ${repo_url}..."
  ./config.sh \
    --unattended \
    --url "$repo_url" \
    --token "$registration_token" \
    --name "$RUNNER_NAME" \
    --labels "$RUNNER_LABELS" \
    --replace

  echo
  echo "Instalando runner como servico..."
  sudo ./svc.sh install
  sudo ./svc.sh start
  sudo ./svc.sh status || true
  cd "$RUNTIME_DIR"
}

health_check() {
  local name="$1"
  local url="$2"
  local i
  for i in $(seq 1 30); do
    if [ "$(curl -s -o /dev/null -w "%{http_code}" "$url" || true)" = "200" ]; then
      echo "$name respondeu em $url"
      return 0
    fi
    sleep 2
  done
  echo "$name nao respondeu em $url" >&2
  return 1
}

clean_old_images() {
  local current_images image
  current_images="$(docker_cmd ps -a --format '{{.Image}}' | sort -u)"
  docker_cmd images "$IMAGE_REPOSITORY" --format '{{.Repository}}:{{.Tag}}' \
    | while read -r image; do
        [ -z "$image" ] && continue
        [ "$image" = "$APP_IMAGE" ] && continue
        echo "$current_images" | grep -qx "$image" && continue
        echo "Removendo imagem antiga: $image"
        docker_cmd rmi "$image" || true
      done
}

deploy() {
  write_compose
  cd "$RUNTIME_DIR"

  if [ -z "$APP_IMAGE" ]; then
    APP_IMAGE="$(latest_integracao_image)"
  fi
  export APP_IMAGE
  export COMPOSE_PROJECT_NAME=receitas-app

  echo
  echo "Imagem selecionada: $APP_IMAGE"
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    echo "$GITHUB_TOKEN" | docker_cmd login ghcr.io -u "$REPO_OWNER" --password-stdin
  fi
  echo "Baixando imagem..."
  docker_cmd pull "$APP_IMAGE"

  if [ "$CLEAN_BEFORE_UP" = "yes" ]; then
    case "$DEPLOY_TARGET" in
      homolog) docker_cmd rm -f receitas_app_homolog >/dev/null 2>&1 || true ;;
      prod) docker_cmd rm -f receitas_app_prod >/dev/null 2>&1 || true ;;
      both) docker_cmd rm -f receitas_app_homolog receitas_app_prod >/dev/null 2>&1 || true ;;
      *) echo "Destino invalido: $DEPLOY_TARGET" >&2; exit 1 ;;
    esac
  fi

  case "$DEPLOY_TARGET" in
    homolog)
      compose_cmd -f "$RUNTIME_DIR/docker-compose.yml" up -d homolog
      health_check "Homologacao" "http://127.0.0.1:5001/login"
      ;;
    prod)
      compose_cmd -f "$RUNTIME_DIR/docker-compose.yml" --profile prod up -d prod
      health_check "Producao" "http://127.0.0.1:5000/login"
      ;;
    both)
      compose_cmd -f "$RUNTIME_DIR/docker-compose.yml" --profile prod up -d homolog prod
      health_check "Homologacao" "http://127.0.0.1:5001/login"
      health_check "Producao" "http://127.0.0.1:5000/login"
      ;;
    *) echo "Destino invalido: $DEPLOY_TARGET" >&2; exit 1 ;;
  esac

  clean_old_images
}

if [ "$NON_INTERACTIVE" != "yes" ]; then
  echo "Preparacao runtime da VM para receitas-app"
  echo
  REPO_OWNER="$(ask "Dono do repositorio" "$REPO_OWNER")"
  REPO_NAME="$(ask "Nome do repositorio" "$REPO_NAME")"
  IMAGE_REPOSITORY="$(ask "Repositorio da imagem Docker" "$IMAGE_REPOSITORY")"
  RUNTIME_DIR="$(ask "Pasta runtime da aplicacao" "$RUNTIME_DIR")"
  RUNNER_NAME="$(ask "Nome do runner" "$RUNNER_NAME")"
  RUNNER_LABELS="$(ask "Labels do runner" "$RUNNER_LABELS")"
  RUNNER_DIR="$(ask "Pasta de instalacao do runner" "$RUNNER_DIR")"
  TOKEN_FILE="$(ask "Arquivo do token GitHub" "$TOKEN_FILE")"
  PUBLIC_HOST="$(ask "IP ou host publico da VM" "$PUBLIC_HOST")"
  if ask_yes_no "Configurar/recriar runner" "s"; then CONFIGURE_RUNNER="yes"; else CONFIGURE_RUNNER="no"; fi
  if ask_yes_no "Instalar dependencias da VM" "s"; then INSTALL_DEPS="yes"; else INSTALL_DEPS="no"; fi
  if ask_yes_no "Remover containers antigos antes de subir" "s"; then CLEAN_BEFORE_UP="yes"; else CLEAN_BEFORE_UP="no"; fi
  DEPLOY_TARGET="$(ask "Ambiente para subir (homolog/prod/both)" "$DEPLOY_TARGET")"
  APP_IMAGE="$(ask "Imagem Docker vazia usa ultimo commit da integracao" "$APP_IMAGE")"
fi

mkdir -p "$RUNTIME_DIR"
cd "$RUNTIME_DIR"

install_deps
configure_runner
deploy

echo
echo "Runtime pronto em: $RUNTIME_DIR"
echo "Homologacao: http://${PUBLIC_HOST}:5001"
echo "Producao:    http://${PUBLIC_HOST}:5000"
