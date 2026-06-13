#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "Rodando lint, mess detector e testes dentro de container Python..."
docker run --rm \
    -v "$PWD":/app \
    -w /app \
    python:3.12-slim \
    sh -c "pip install --no-cache-dir -r requirements-dev.txt && pyflakes app.py init_db.py tests && radon cc app.py init_db.py tests -s -a && radon mi app.py init_db.py tests -s && pytest -q"

echo "Checks em Docker concluidos."
