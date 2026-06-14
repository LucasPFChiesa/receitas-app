#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/LucasPFChiesa/receitas-app.git"
BRANCH="configurando-com-docker"
APP_DIR="$HOME/receitas-app"

echo "Conferindo estado inicial da VM..."
echo
echo "Pasta home:"
ls -la "$HOME"

echo
if [ -d "$APP_DIR" ]; then
    echo "Projeto encontrado em: $APP_DIR"
else
    echo "Projeto receitas-app ainda nao existe na VM."
fi

echo
if command -v docker >/dev/null 2>&1; then
    echo "Containers existentes:"
    sudo docker ps -a || true

    echo
    echo "Imagens existentes:"
    sudo docker images || true
else
    echo "Docker ainda nao instalado."
fi

echo
echo "Instalando dependencias da VM..."
sudo apt update
sudo apt install -y git docker.io docker-compose curl
sudo systemctl enable --now docker

echo "Baixando projeto..."
rm -rf "$APP_DIR"
git clone --branch "$BRANCH" "$REPO_URL" "$APP_DIR"

cd "$APP_DIR"
chmod +x docker-entrypoint.sh scripts/*.sh

echo "Preparando imagens Docker..."
sh scripts/docker-compose.sh -f docker-compose.vm.yml build homolog prod

echo
echo "Containers apos a preparacao:"
sh scripts/docker-compose.sh -f docker-compose.vm.yml --profile prod ps

echo "VM preparada."
echo "Nenhum container foi iniciado."
echo "Projeto: $APP_DIR"
echo "Para subir homologacao: cd $APP_DIR && scripts/subir_homologacao.sh"
echo "Para subir producao:    cd $APP_DIR && scripts/subir_producao.sh"
