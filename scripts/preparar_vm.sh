#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/LucasPFChiesa/receitas-app.git"
BRANCH="configurando-com-docker"
APP_DIR="$HOME/receitas-app"
TOKEN_FILE="$HOME/keys/github_token.txt"

if [ ! -f "$TOKEN_FILE" ]; then
    echo "Token do GitHub nao encontrado."
    echo "Crie o arquivo: $TOKEN_FILE"
    exit 1
fi

GITHUB_TOKEN="$(tr -d '\r\n' < "$TOKEN_FILE")"
AUTH_HEADER="$(printf 'x-access-token:%s' "$GITHUB_TOKEN" | base64 | tr -d '\n')"

echo "Instalando dependencias da VM..."
sudo apt update
sudo apt install -y git docker.io docker-compose curl
sudo systemctl enable --now docker

echo "Baixando projeto..."
rm -rf "$APP_DIR"
git -c "http.https://github.com/.extraheader=AUTHORIZATION: basic $AUTH_HEADER" clone --branch "$BRANCH" "$REPO_URL" "$APP_DIR"

cd "$APP_DIR"
chmod +x docker-entrypoint.sh scripts/*.sh

echo "Preparando imagens Docker..."
sh scripts/docker-compose.sh -f docker-compose.vm.yml build homolog prod

echo "VM preparada."
echo "Nenhum container foi iniciado."
echo "Projeto: $APP_DIR"
echo "Para subir homologacao: cd $APP_DIR && scripts/subir_homologacao.sh"
echo "Para subir producao:    cd $APP_DIR && scripts/subir_producao.sh"
