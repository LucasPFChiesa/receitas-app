import app as app_module


def test_exportacao_pdf_retorna_content_type_correto():
    client = app_module.app.test_client()

    client.post(
        "/login",
        data={"login": "admin", "senha": "admin123"},
        follow_redirects=False
    )

    resposta = client.get("/receitas/pdf", follow_redirects=False)

    assert resposta.status_code == 200
    assert resposta.content_type == "application/pdf"

def test_exportacao_pdf_comeca_com_assinatura_pdf():
    client = app_module.app.test_client()

    client.post(
        "/login",
        data={"login": "admin", "senha": "admin123"},
        follow_redirects=False
    )

    resposta = client.get("/receitas/pdf", follow_redirects=False)

    assert resposta.status_code == 200
    assert resposta.data[:4] == b"%PDF"