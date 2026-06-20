import os
import sqlite3
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
DB_PATH = Path(os.getenv('DATABASE_PATH', BASE_DIR / 'receitas.db'))
MIGRATIONS_DIR = BASE_DIR / 'migrations'


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
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    migrations = apply_migrations(conn)
    conn.commit()
    conn.close()

    print('Banco verificado com sucesso em:', DB_PATH)

    if migrations:
        print('Migrations aplicadas:', ', '.join(migrations))
    else:
        print('Nenhuma migration pendente.')


if __name__ == '__main__':
    main()
