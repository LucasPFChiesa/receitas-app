#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

BRANCH="$(git branch --show-current)"

if [ ! -f "$HOME/.git-credentials" ]; then
    echo "Token do GitHub nao configurado."
    echo "Execute: scripts/configurar_git_token.sh"
    exit 1
fi

git push -u origin "$BRANCH"
