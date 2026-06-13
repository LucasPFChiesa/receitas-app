#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "Criando ambiente Python, instalando dependencias, lint e testes..."
python3 -m venv .venv
. .venv/bin/activate
pip install --upgrade pip
pip install -r requirements-dev.txt
pyflakes app.py init_db.py tests
pytest -q

echo "Checks concluidos."
