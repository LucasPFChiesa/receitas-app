#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "Parando container de desenvolvimento..."
sh scripts/docker-compose.sh stop dev
