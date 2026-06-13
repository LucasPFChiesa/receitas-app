#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

sh scripts/docker-compose.sh logs -f dev
