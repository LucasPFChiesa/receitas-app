import sys
import sqlite3
from pathlib import Path
import tempfile
import shutil

sys.path.append(str(Path(__file__).resolve().parent.parent))

import app as app_module


def criar_banco_temporario():
    arquivo_temp = tempfile.NamedTemporaryFile(delete=False, suffix=".db")
    caminho_temp = Path(arquivo_temp.name)
    arquivo_temp.close()

    conn = sqlite3.connect(caminho_temp)

    schema = Path("schema.sql").read_text(encoding="utf-8")
    seed = Path("seed.sql").read_text(encoding="utf-8")

    conn.executescript(schema)
    conn.executescript(seed)
    conn.commit()
    conn.close()

    return caminho_temp


def pytest_runtest_setup(item):
    banco_teste = criar_banco_temporario()
    item._banco_teste = banco_teste
    app_module.DB_PATH = banco_teste
    app_module.app.config["TESTING"] = True


def pytest_runtest_teardown(item, nextitem):
    banco_teste = getattr(item, "_banco_teste", None)
    if banco_teste and banco_teste.exists():
        banco_teste.unlink()