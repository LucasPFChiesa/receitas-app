#!/usr/bin/env bash
set -e

echo "Limpando containers, imagens, volumes nao usados e cache do Docker..."

containers="$(sudo docker ps -a -q)"
if [ -n "$containers" ]; then
    echo "Parando containers..."
    sudo docker stop $containers

    echo "Removendo containers..."
    sudo docker rm $containers
else
    echo "Nenhum container encontrado."
fi

images="$(sudo docker images -a -q)"
if [ -n "$images" ]; then
    echo "Removendo imagens..."
    sudo docker rmi -f $images
else
    echo "Nenhuma imagem encontrada."
fi

echo "Removendo caches e recursos nao usados..."
sudo docker system prune -a --volumes -f

echo "Limpeza Docker concluida."
