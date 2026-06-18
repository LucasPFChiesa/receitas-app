  GNU nano 7.2                 clean_docker_images.sh                           
#! /bin/bash

# parar todos os containers
sudo docker stop $(sudo docker ps -a -q)

# deletar todos os containers
sudo docker rm $(sudo docker ps -a -q)

# deletar todas as imagens
sudo docker rmi $(sudo docker images -a -q)

# deletar: caches e builds - limpeza geral
sudo docker system prune -a -f



