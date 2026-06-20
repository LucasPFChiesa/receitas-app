import sys
from pathlib import Path
import tempfile

sys.path.append(str(Path(__file__).resolve().parent.parent))

import app as app_module
import init_db


def criar_banco_temporario():
    arquivo_temp = tempfile.NamedTemporaryFile(delete=False, suffix=".db")
    caminho_temp = Path(arquivo_temp.name)
    arquivo_temp.close()

    original_db_path = init_db.DB_PATH
    init_db.DB_PATH = caminho_temp
    try:
        init_db.main()
    finally:
        init_db.DB_PATH = original_db_path

    return caminho_temp


def pytest_runtest_setup(item):
    banco_teste = criar_banco_temporario()
    item._banco_teste = banco_teste
    app_module.DB_PATH = banco_teste
    init_db.DB_PATH = banco_teste
    app_module.app.config["TESTING"] = True


def pytest_runtest_teardown(item, nextitem):
    banco_teste = getattr(item, "_banco_teste", None)
    if banco_teste and banco_teste.exists():
        banco_teste.unlink()
