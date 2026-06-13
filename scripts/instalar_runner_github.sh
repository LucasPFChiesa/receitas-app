#!/usr/bin/env bash
set -e

if [ -z "$RUNNER_TOKEN" ]; then
    echo "Informe RUNNER_TOKEN antes de executar."
    echo "Exemplo: RUNNER_TOKEN=xxxxx scripts/instalar_runner_github.sh"
    exit 1
fi

RUNNER_DIR="$HOME/actions-runner"
RUNNER_VERSION="2.328.0"
REPO_URL="https://github.com/LucasPFChiesa/receitas-app"

mkdir -p "$RUNNER_DIR"
cd "$RUNNER_DIR"

if [ ! -f "config.sh" ]; then
    curl -L -o actions-runner-linux-x64.tar.gz \
        "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
    tar xzf actions-runner-linux-x64.tar.gz
fi

if [ ! -f ".runner" ]; then
    ./config.sh \
        --url "$REPO_URL" \
        --token "$RUNNER_TOKEN" \
        --name "receitas-vm" \
        --labels "self-hosted,linux,receitas-vm" \
        --unattended \
        --replace
fi

sudo ./svc.sh install
sudo ./svc.sh start
sudo ./svc.sh status
