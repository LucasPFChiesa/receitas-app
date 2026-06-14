#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

BRANCH="$(git branch --show-current)"
TOKEN_FILE="$HOME/keys/github_token.txt"

if [ ! -f "$TOKEN_FILE" ]; then
    echo "Token do GitHub nao encontrado."
    echo "Crie o arquivo: $TOKEN_FILE"
    exit 1
fi

GITHUB_TOKEN="$(tr -d '\r\n' < "$TOKEN_FILE")"
AUTH_HEADER="$(printf 'x-access-token:%s' "$GITHUB_TOKEN" | base64 | tr -d '\n')"

git -c "http.https://github.com/.extraheader=AUTHORIZATION: basic $AUTH_HEADER" pull origin "$BRANCH"
