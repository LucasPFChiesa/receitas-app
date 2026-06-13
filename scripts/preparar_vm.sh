#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/LucasPFChiesa/receitas-app.git"
BRANCH="configurando-com-docker"
APP_DIR="$HOME/receitas-app"
TOKEN_FILE="$HOME/keys/github_token.txt"

if [ -z "${GITHUB_TOKEN:-}" ] && [ -f "$TOKEN_FILE" ]; then
    GITHUB_TOKEN="$(tr -d '\n\r ' < "$TOKEN_FILE")"
fi

if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo "Informe o token do GitHub em GITHUB_TOKEN ou em $TOKEN_FILE."
    exit 1
fi

echo "Instalando dependencias da VM..."
sudo apt update
sudo apt install -y git docker.io docker-compose curl
sudo systemctl enable --now docker

echo "Baixando projeto..."
rm -rf "$APP_DIR"
git -c credential.helper= \
    -c "http.https://github.com/.extraheader=AUTHORIZATION: basic $(printf 'LucasPFChiesa:%s' "$GITHUB_TOKEN" | base64 -w 0)" \
    clone --branch "$BRANCH" "$REPO_URL" "$APP_DIR"

cd "$APP_DIR"
chmod +x docker-entrypoint.sh scripts/*.sh
mkdir -p keys
printf '%s\n' "$GITHUB_TOKEN" > keys/github_token.txt
chmod 600 keys/github_token.txt

echo "Preparando imagens Docker..."
sh scripts/docker-compose.sh -f docker-compose.vm.yml build homolog prod

echo "VM preparada."
echo "Nenhum container foi iniciado."
echo "Projeto: $APP_DIR"
echo "Para subir homologacao: cd $APP_DIR && scripts/subir_homologacao.sh"
echo "Para subir producao:    cd $APP_DIR && scripts/subir_producao.sh"
