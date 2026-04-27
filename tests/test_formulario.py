import app as app_module


def test_formulario_nova_receita_exibe_campo_status():
    client = app_module.app.test_client()

    client.post(
        "/login",
        data={"login": "admin", "senha": "admin123"},
        follow_redirects=False
    )

    resposta = client.get("/receitas/nova", follow_redirects=True)

    assert resposta.status_code == 200
    assert b'name="status"' in resposta.data
    assert b"ativa" in resposta.data.lower()
    assert b"inativa" in resposta.data.lower()

def test_formulario_edicao_marca_status_atual_da_receita():
    client = app_module.app.test_client()

    client.post(
        "/login",
        data={"login": "admin", "senha": "admin123"},
        follow_redirects=False
    )

    resposta = client.get("/receitas/editar/4", follow_redirects=True)

    assert resposta.status_code == 200
    assert b'value="inativa"' in resposta.data
    assert b"selected" in resposta.data