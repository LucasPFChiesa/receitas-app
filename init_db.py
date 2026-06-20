import os
import sqlite3
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
DB_PATH = Path(os.getenv('DATABASE_PATH', BASE_DIR / 'receitas.db'))
SCHEMA_PATH = BASE_DIR / 'schema.sql'
SEED_PATH = BASE_DIR / 'seed.sql'
MIGRATIONS_DIR = BASE_DIR / 'migrations'


def table_exists(conn, table_name):
    row = conn.execute(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
        (table_name,),
    ).fetchone()
    return row is not None


def initialize_database(conn):
    if table_exists(conn, 'usuario') and table_exists(conn, 'receita'):
        return False

    with open(SCHEMA_PATH, 'r', encoding='utf-8') as f:
        conn.executescript(f.read())
    with open(SEED_PATH, 'r', encoding='utf-8') as f:
        conn.executescript(f.read())
    return True


def ensure_migrations_table(conn):
    conn.execute(
        '''
        CREATE TABLE IF NOT EXISTS schema_migrations (
            filename TEXT PRIMARY KEY,
            applied_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
        '''
    )


def applied_migrations(conn):
    ensure_migrations_table(conn)
    rows = conn.execute('SELECT filename FROM schema_migrations').fetchall()
    return {row[0] for row in rows}


def migration_files():
    if not MIGRATIONS_DIR.exists():
        return []
    return sorted(MIGRATIONS_DIR.glob('*.sql'))


def apply_migrations(conn):
    applied = applied_migrations(conn)
    pending = [path for path in migration_files() if path.name not in applied]

    for path in pending:
        sql = path.read_text(encoding='utf-8')
        conn.executescript(sql)
        conn.execute(
            'INSERT INTO schema_migrations (filename) VALUES (?)',
            (path.name,),
        )

    return [path.name for path in pending]


def main():
    conn = sqlite3.connect(DB_PATH)
    initialized = initialize_database(conn)
    migrations = apply_migrations(conn)
    conn.commit()
    conn.close()

    if initialized:
        print('Banco criado e populado com sucesso em:', DB_PATH)
    else:
        print('Banco existente encontrado em:', DB_PATH)

    if migrations:
        print('Migrations aplicadas:', ', '.join(migrations))
    else:
        print('Nenhuma migration pendente.')


if __name__ == '__main__':
    main()
