import sqlite3

import init_db


def test_migration_base_cria_tabelas_principais():
    conn = sqlite3.connect(init_db.DB_PATH)

    tabelas = {
        row[0]
        for row in conn.execute(
            "SELECT name FROM sqlite_master WHERE type = 'table'"
        ).fetchall()
    }
    total_usuarios = conn.execute('SELECT COUNT(*) FROM usuario').fetchone()[0]
    total_receitas = conn.execute('SELECT COUNT(*) FROM receita').fetchone()[0]
    conn.close()

    assert 'usuario' in tabelas
    assert 'receita' in tabelas
    assert total_usuarios == 1
    assert total_receitas == 10


def test_migrations_sql_sao_registradas():
    conn = sqlite3.connect(init_db.DB_PATH)

    # Qualquer arquivo .sql em migrations deve ser aceito e registrado.
    migrations_no_disco = [path.name for path in init_db.migration_files()]
    registros = conn.execute(
        'SELECT filename FROM schema_migrations ORDER BY filename'
    ).fetchall()
    conn.close()

    assert [row[0] for row in registros] == migrations_no_disco


def test_migration_pode_rodar_novamente_sem_duplicar_dados():
    conn = sqlite3.connect(init_db.DB_PATH)

    init_db.apply_migrations(conn)
    init_db.apply_migrations(conn)
    conn.commit()

    total_arquivos_sql = len(init_db.migration_files())
    total_migrations = conn.execute(
        'SELECT COUNT(*) FROM schema_migrations'
    ).fetchone()[0]
    conn.close()

    assert total_migrations == total_arquivos_sql


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
    conn.close()

    assert receita is not None
