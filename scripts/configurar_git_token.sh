#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

if [ -z "${GITHUB_TOKEN:-}" ]; then
    printf "Cole o token do GitHub: "
    stty -echo
    read -r GITHUB_TOKEN
    stty echo
    printf "\n"
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Token vazio."
    exit 1
fi

git config --global credential.helper store
printf 'https://LucasPFChiesa:%s@github.com\n' "$GITHUB_TOKEN" > "$HOME/.git-credentials"
chmod 600 "$HOME/.git-credentials"

echo "Token configurado para o usuario atual."
