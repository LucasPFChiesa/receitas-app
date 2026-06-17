#!/usr/bin/env bash
set -euo pipefail

VM_HOST="${1:-${VM_HOST:-177.44.248.83}}"
VM_USER="${2:-${VM_USER:-univates}}"
RUNNER_SERVICE="${RUNNER_SERVICE:-actions.runner.LucasPFChiesa-receitas-app.receitas-app-vm.service}"

ssh "${VM_USER}@${VM_HOST}" "sudo systemctl start ${RUNNER_SERVICE} && sudo systemctl status ${RUNNER_SERVICE} --no-pager | head -n 12"
