DROP TABLE IF EXISTS receita;
DROP TABLE IF EXISTS usuario;

CREATE TABLE usuario (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    login TEXT NOT NULL UNIQUE,
    senha TEXT NOT NULL,
    situacao TEXT NOT NULL
);

CREATE TABLE receita (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    descricao TEXT NOT NULL,
    data_registro TEXT NOT NULL,
    custo REAL NOT NULL,
    tipo_receita TEXT NOT NULL CHECK (tipo_receita IN ('doce', 'salgada'))
);
