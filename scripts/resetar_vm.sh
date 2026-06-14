#!/usr/bin/env bash
set -e

APP_DIR="$HOME/receitas-app"

echo "Parando e removendo containers..."
CONTAINERS="$(sudo docker ps -a -q 2>/dev/null || true)"
if [ -n "$CONTAINERS" ]; then
    sudo docker stop $CONTAINERS
    sudo docker rm $CONTAINERS
else
    echo "Nenhum container encontrado."
fi

echo
echo "Removendo imagens..."
IMAGES="$(sudo docker images -a -q 2>/dev/null || true)"
if [ -n "$IMAGES" ]; then
    sudo docker rmi $IMAGES
else
    echo "Nenhuma imagem encontrada."
fi

echo
echo "Limpando cache Docker..."
sudo docker system prune -a -f

echo
echo "Removendo projeto da VM..."
cd "$HOME"
rm -rf "$APP_DIR" "$HOME/preparar_vm.sh"

echo
echo "VM resetada para a apresentacao."
echo "Token mantido em: $HOME/keys/github_token.txt"
