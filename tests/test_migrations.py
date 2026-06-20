import sqlite3

import init_db


def test_migration_cria_tabela_categoria():
    conn = sqlite3.connect(init_db.DB_PATH)

    tabela = conn.execute(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'categoria'"
    ).fetchone()
    categorias = conn.execute(
        'SELECT nome FROM categoria ORDER BY id'
    ).fetchall()
    conn.close()

    assert tabela is not None
    assert [row[0] for row in categorias] == ['Doce', 'Salgada']


def test_migration_registra_arquivo_aplicado():
    conn = sqlite3.connect(init_db.DB_PATH)

    registro = conn.execute(
        'SELECT filename FROM schema_migrations WHERE filename = ?',
        ('001_create_categoria.sql',),
    ).fetchone()
    conn.close()

    assert registro is not None


def test_migration_pode_rodar_novamente_sem_duplicar_dados():
    conn = sqlite3.connect(init_db.DB_PATH)

    init_db.apply_migrations(conn)
    init_db.apply_migrations(conn)
    conn.commit()

    total_categorias = conn.execute('SELECT COUNT(*) FROM categoria').fetchone()[0]
    total_migrations = conn.execute(
        'SELECT COUNT(*) FROM schema_migrations WHERE filename = ?',
        ('001_create_categoria.sql',),
    ).fetchone()[0]
    conn.close()

    assert total_categorias == 2
    assert total_migrations == 1


def test_inicializador_preserva_banco_existente_ao_aplicar_migrations():
    conn = sqlite3.connect(init_db.DB_PATH)
    conn.execute(
        'INSERT INTO receita '
        '(nome, descricao, data_registro, custo, tipo_receita, status) '
        'VALUES (?, ?, ?, ?, ?, ?)',
        ('Receita Persistente', 'Nao pode sumir', '2026-06-19', 10, 'doce', 'ativa'),
    )
    conn.commit()
    conn.close()

    init_db.main()

    conn = sqlite3.connect(init_db.DB_PATH)
    receita = conn.execute(
        'SELECT nome FROM receita WHERE nome = ?',
        ('Receita Persistente',),
    ).fetchone()
    categoria = conn.execute(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'categoria'"
    ).fetchone()
    conn.close()

    assert receita is not None
    assert categoria is not None
