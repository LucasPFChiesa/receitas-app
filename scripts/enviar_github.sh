#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

MENSAGEM="${1:-Atualiza projeto}"

echo "Arquivos alterados:"
git status --short

echo
echo "Preparando commit..."
git add .

if git diff --cached --quiet; then
    echo "Nenhuma alteracao para commitar."
else
    git commit -m "$MENSAGEM"
fi

echo
echo "Enviando para o GitHub..."
git push

echo
echo "Integracao:"
echo "https://github.com/LucasPFChiesa/receitas-app/actions"
