#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="${REPO_OWNER:-LucasPFChiesa}"
REPO_NAME="${REPO_NAME:-receitas-app}"
RUNNER_DIR="${RUNNER_DIR:-$HOME/actions-runner}"
TOKEN_FILE="${TOKEN_FILE:-$HOME/keys/github_token.txt}"

if [ ! -d "$RUNNER_DIR" ]; then
  echo "Runner nao encontrado em $RUNNER_DIR"
  exit 0
fi

cd "$RUNNER_DIR"

echo "Parando e removendo servico local..."
if [ -f ./svc.sh ]; then
  sudo ./svc.sh stop || true
  sudo ./svc.sh uninstall || true
fi

if [ -f .runner ] && [ -f "$TOKEN_FILE" ]; then
  GITHUB_TOKEN="$(tr -d "\r\n" < "$TOKEN_FILE")"
  REMOVE_TOKEN="$(
    curl -fsSL \
      -X POST \
      -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -H "Accept: application/vnd.github+json" \
      "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runners/remove-token" \
      | python3 -c "import json,sys; print(json.load(sys.stdin)['token'])"
  )"
  ./config.sh remove --token "$REMOVE_TOKEN" || true
fi

cd "$HOME"
rm -rf "$RUNNER_DIR"

echo "Runner removido da VM."
