#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

TOKEN_FILE="keys/github_token.txt"
REPO_URL="https://github.com/LucasPFChiesa/receitas-app.git"
BRANCH="$(git branch --show-current)"

if [ ! -f "$TOKEN_FILE" ]; then
    echo "Arquivo $TOKEN_FILE nao encontrado."
    exit 1
fi

TOKEN="$(tr -d '\n\r ' < "$TOKEN_FILE")"

if [ -z "$TOKEN" ] || [ "$TOKEN" = "COLE_SEU_TOKEN_AQUI" ]; then
    echo "Cole o token do GitHub em $TOKEN_FILE antes de executar."
    exit 1
fi

git -c credential.helper= \
    -c "http.https://github.com/.extraheader=AUTHORIZATION: basic $(printf 'LucasPFChiesa:%s' "$TOKEN" | base64 -w 0)" \
    pull "$REPO_URL" "$BRANCH"
