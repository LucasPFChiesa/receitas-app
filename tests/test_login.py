from flask import session
from app import app


def test_pagina_login_carrega():
    client = app.test_client()
    resposta = client.get("/login")

    assert resposta.status_code == 200


def test_login_invalido_nao_redireciona():
    client = app.test_client()
    resposta = client.post(
        "/login",
        data={"login": "admin", "senha": "errada"},
        follow_redirects=False
    )

    assert resposta.status_code == 200


def test_login_valido_redireciona_para_receitas():
    client = app.test_client()
    resposta = client.post(
        "/login",
        data={"login": "admin", "senha": "admin123"},
        follow_redirects=False
    )

    assert resposta.status_code == 302
    assert "/receitas" in resposta.headers["Location"]


def test_login_valido_grava_dados_na_sessao():
    client = app.test_client()

    with client:
        client.post(
            "/login",
            data={"login": "admin", "senha": "admin123"},
            follow_redirects=False
        )

        assert "usuario_id" in session
        assert session["usuario_nome"] == "Administrador"

def test_login_invalido_exibe_mensagem_de_erro():
    client = app.test_client()

    resposta = client.post(
        "/login",
        data={"login": "admin", "senha": "errada"},
        follow_redirects=True
    )

    assert resposta.status_code == 200
    assert b"inv" in resposta.data.lower()