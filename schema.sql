-- Arquivo de referencia.
-- A estrutura oficial do banco fica versionada em migrations/.

CREATE TABLE IF NOT EXISTS usuario (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    login TEXT NOT NULL UNIQUE,
    senha TEXT NOT NULL,
    situacao TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS receita (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    descricao TEXT NOT NULL,
    data_registro TEXT NOT NULL,
    custo REAL NOT NULL,
    tipo_receita TEXT NOT NULL CHECK (tipo_receita IN ('doce', 'salgada')),
    status TEXT NOT NULL CHECK (status IN ('ativa', 'inativa'))
);

CREATE TABLE IF NOT EXISTS categoria (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL UNIQUE,
    situacao TEXT NOT NULL DEFAULT 'ativa' CHECK (situacao IN ('ativa', 'inativa'))
);

CREATE TABLE IF NOT EXISTS schema_migrations (
    filename TEXT PRIMARY KEY,
    applied_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
