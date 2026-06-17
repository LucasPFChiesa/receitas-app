#!/usr/bin/env bash
set -euo pipefail

IMAGE_REPOSITORY="${IMAGE_REPOSITORY:-ghcr.io/lucaspfchiesa/receitas-app}"

CURRENT_IMAGES="$(sudo docker ps --format '{{.Image}}' | sort -u)"

sudo docker images "$IMAGE_REPOSITORY" --format '{{.Repository}}:{{.Tag}}' \
  | while read -r IMAGE; do
      [ -z "$IMAGE" ] && continue
      if echo "$CURRENT_IMAGES" | grep -qx "$IMAGE"; then
        echo "Mantendo imagem em uso: $IMAGE"
        continue
      fi
      echo "Removendo imagem antiga: $IMAGE"
      sudo docker rmi "$IMAGE" || true
    done
