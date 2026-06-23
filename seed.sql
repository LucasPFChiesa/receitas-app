-- Arquivo de referencia.
-- Os dados iniciais oficiais ficam versionados em migrations/.

INSERT OR IGNORE INTO usuario (id, nome, login, senha, situacao) VALUES
(1, 'Administrador', 'admin', 'admin123', 'ativo');

INSERT OR IGNORE INTO receita
(id, nome, descricao, data_registro, custo, tipo_receita, status)
VALUES
(1, 'Brigadeiro Tradicional', 'Doce de leite condensado, chocolate em pó e granulado.', '2026-03-31', 18.50, 'doce', 'ativa'),
(2, 'Beijinho', 'Doce de coco com leite condensado e açúcar cristal.', '2026-03-31', 17.00, 'doce', 'ativa'),
(3, 'Cuca de Banana', 'Massa doce com cobertura crocante e bananas.', '2026-03-31', 22.90, 'doce', 'ativa'),
(4, 'Pudim de Leite', 'Sobremesa assada com calda de caramelo.', '2026-03-31', 24.00, 'doce', 'inativa'),
(5, 'Bolo de Cenoura', 'Bolo com cobertura de chocolate.', '2026-03-31', 26.30, 'doce', 'ativa'),
(6, 'Coxinha de Frango', 'Salgado frito recheado com frango desfiado.', '2026-03-31', 35.00, 'salgada', 'ativa'),
(7, 'Risoles de Queijo', 'Massa salgada recheada com queijo.', '2026-03-31', 28.50, 'salgada', 'inativa'),
(8, 'Pastel de Carne', 'Pastel frito recheado com carne moída temperada.', '2026-03-31', 33.20, 'salgada', 'ativa'),
(9, 'Empada de Frango', 'Massa amanteigada com recheio de frango.', '2026-03-31', 31.00, 'salgada', 'ativa'),
(10, 'Pão de Queijo', 'Bolinhas assadas com polvilho e queijo.', '2026-03-31', 19.80, 'salgada', 'ativa');
