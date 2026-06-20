CREATE TABLE IF NOT EXISTS categoria (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL UNIQUE,
    situacao TEXT NOT NULL DEFAULT 'ativa' CHECK (situacao IN ('ativa', 'inativa'))
);

INSERT OR IGNORE INTO categoria (nome, situacao) VALUES
('Doce', 'ativa'),
('Salgada', 'ativa');
