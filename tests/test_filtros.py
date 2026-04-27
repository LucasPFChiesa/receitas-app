import app as app_module


def test_filtro_status_inativa_exibe_receitas_inativas():
    client = app_module.app.test_client()

    client.post(
        "/login",
        data={"login": "admin", "senha": "admin123"},
        follow_redirects=False
    )

    resposta = client.get("/receitas?status=inativa", follow_redirects=True)

    assert resposta.status_code == 200
    assert b"pudim de leite" in resposta.data.lower()
    assert b"risoles de queijo" in resposta.data.lower()

def test_filtro_status_inativa_nao_exibe_receitas_ativas():
    client = app_module.app.test_client()

    client.post(
        "/login",
        data={"login": "admin", "senha": "admin123"},
        follow_redirects=False
    )

    resposta = client.get("/receitas?status=inativa", follow_redirects=True)

    assert resposta.status_code == 200
    assert b"brigadeiro tradicional" not in resposta.data.lower()
    assert b"coxinha de frango" not in resposta.data.lower()

def test_filtro_data_inicial_sem_resultados_retorna_lista_vazia():
    client = app_module.app.test_client()

    client.post(
        "/login",
        data={"login": "admin", "senha": "admin123"},
        follow_redirects=False
    )

    resposta = client.get("/receitas?data_inicio=2030-01-01", follow_redirects=True)

    assert resposta.status_code == 200
    assert b"brigadeiro tradicional" not in resposta.data.lower()
    assert b"coxinha de frango" not in resposta.data.lower()

def test_filtro_data_final_mantem_receitas_da_data_seed():
    client = app_module.app.test_client()

    client.post(
        "/login",
        data={"login": "admin", "senha": "admin123"},
        follow_redirects=False
    )

    resposta = client.get("/receitas?data_fim=2026-03-31", follow_redirects=True)

    assert resposta.status_code == 200
    assert b"brigadeiro tradicional" in resposta.data.lower()
    assert b"p\xc3\xa3o de queijo" in resposta.data.lower()