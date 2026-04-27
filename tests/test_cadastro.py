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
            "status": "ativa",
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
            "status": "ativa",
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
            "status": "ativa",
        },
        follow_redirects=False
    )

    assert resposta.status_code == 302
    assert "/receitas" in resposta.headers["Location"]

def test_cadastro_exibe_nova_receita_na_listagem():
    client = app_module.app.test_client()

    client.post(
        "/login",
        data={"login": "admin", "senha": "admin123"},
        follow_redirects=False
    )

    resposta = client.post(
        "/receitas/nova",
        data={
            "nome": "Canjica Teste",
            "descricao": "Doce com leite",
            "data_registro": "2026-04-26",
            "custo": "18.00",
            "tipo_receita": "doce",
            "status": "ativa",
        },
        follow_redirects=True
    )

    assert resposta.status_code == 200
    assert b"canjica teste" in resposta.data.lower()

def test_edicao_altera_nome_no_banco():
    client = app_module.app.test_client()

    client.post(
        "/login",
        data={"login": "admin", "senha": "admin123"},
        follow_redirects=False
    )

    resposta = client.post(
        "/receitas/editar/1",
        data={
            "nome": "Brigadeiro Editado",
            "descricao": "Doce de leite condensado, chocolate em pó e granulado.",
            "data_registro": "2026-03-31",
            "custo": "18.50",
            "tipo_receita": "doce",
            "status": "ativa",
        },
        follow_redirects=False
    )

    conn = sqlite3.connect(app_module.DB_PATH)
    registro = conn.execute(
        "SELECT nome FROM receita WHERE id = 1"
    ).fetchone()
    conn.close()

    assert resposta.status_code == 302
    assert registro[0] == "Brigadeiro Editado"

def test_edicao_de_id_inexistente_nao_altera_lista():
    client = app_module.app.test_client()

    client.post(
        "/login",
        data={"login": "admin", "senha": "admin123"},
        follow_redirects=False
    )

    resposta = client.post(
        "/receitas/editar/999",
        data={
            "nome": "Receita Fantasma",
            "descricao": "Nao existe",
            "data_registro": "2026-04-26",
            "custo": "10.00",
            "tipo_receita": "doce",
            "status": "ativa",
        },
        follow_redirects=True
    )

    assert resposta.status_code == 200
    assert b"receita n\xc3\xa3o encontrada" in resposta.data.lower()

def test_exclusao_remove_receita_do_banco():
    client = app_module.app.test_client()

    client.post(
        "/login",
        data={"login": "admin", "senha": "admin123"},
        follow_redirects=False
    )

    conn = sqlite3.connect(app_module.DB_PATH)
    antes = conn.execute("SELECT COUNT(*) FROM receita").fetchone()[0]
    conn.close()

    resposta = client.post("/receitas/excluir/1", follow_redirects=False)

    conn = sqlite3.connect(app_module.DB_PATH)
    depois = conn.execute("SELECT COUNT(*) FROM receita").fetchone()[0]
    registro = conn.execute("SELECT * FROM receita WHERE id = 1").fetchone()
    conn.close()

    assert resposta.status_code == 302
    assert depois == antes - 1
    assert registro is None

def test_exclusao_redireciona_para_listagem():
    client = app_module.app.test_client()

    client.post(
        "/login",
        data={"login": "admin", "senha": "admin123"},
        follow_redirects=False
    )

    resposta = client.post("/receitas/excluir/2", follow_redirects=False)

    assert resposta.status_code == 302
    assert "/receitas" in resposta.headers["Location"]