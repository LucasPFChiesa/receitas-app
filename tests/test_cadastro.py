import sqlite3
import app as app_module


def contar_receitas():
    conn = sqlite3.connect(app_module.DB_PATH)
    total = conn.execute("SELECT COUNT(*) FROM receita").fetchone()[0]
    conn.close()
    return total


def test_cadastro_aumenta_quantidade_de_receitas():
    client = app_module.app.test_client()

    client.post(
        "/login",
        data={"login": "admin", "senha": "admin123"},
        follow_redirects=False
    )

    antes = contar_receitas()

    client.post(
        "/receitas/nova",
        data={
            "nome": "Torta Teste",
            "descricao": "Receita criada no teste",
            "data_registro": "2026-04-26",
            "custo": "29.90",
            "tipo_receita": "doce",
        },
        follow_redirects=False
    )

    depois = contar_receitas()

    assert depois == antes + 1

def test_cadastro_salva_nome_correto_no_banco():
    client = app_module.app.test_client()

    client.post(
        "/login",
        data={"login": "admin", "senha": "admin123"},
        follow_redirects=False
    )

    client.post(
        "/receitas/nova",
        data={
            "nome": "Quindim Teste",
            "descricao": "Doce amarelo",
            "data_registro": "2026-04-26",
            "custo": "15.50",
            "tipo_receita": "doce",
        },
        follow_redirects=False
    )

    conn = sqlite3.connect(app_module.DB_PATH)
    registro = conn.execute(
        "SELECT nome FROM receita WHERE nome = ?",
        ("Quindim Teste",)
    ).fetchone()
    conn.close()

    assert registro is not None
    assert registro[0] == "Quindim Teste"

def test_cadastro_redireciona_para_listagem():
    client = app_module.app.test_client()

    client.post(
        "/login",
        data={"login": "admin", "senha": "admin123"},
        follow_redirects=False
    )

    resposta = client.post(
        "/receitas/nova",
        data={
            "nome": "Ambrosia Teste",
            "descricao": "Doce tradicional",
            "data_registro": "2026-04-26",
            "custo": "21.00",
            "tipo_receita": "doce",
        },
        follow_redirects=False
    )

    assert resposta.status_code == 302
    assert "/receitas" in resposta.headers["Location"]