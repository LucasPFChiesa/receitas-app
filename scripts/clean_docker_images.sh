#!/usr/bin/env bash
set -e

# parar todos os containers
CONTAINERS="$(sudo docker ps -a -q)"
if [ -n "$CONTAINERS" ]; then
    sudo docker stop $CONTAINERS
else
    echo "Nenhum container para parar."
fi

# deletar todos os containers
CONTAINERS="$(sudo docker ps -a -q)"
if [ -n "$CONTAINERS" ]; then
    sudo docker rm $CONTAINERS
else
    echo "Nenhum container para deletar."
fi

# deletar todas as imagens
IMAGES="$(sudo docker images -a -q)"
if [ -n "$IMAGES" ]; then
    sudo docker rmi $IMAGES
else
    echo "Nenhuma imagem para deletar."
fi

# deletar: caches e builds - limpeza geral
sudo docker system prune -a -f
