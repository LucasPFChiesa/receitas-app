# Sistema de Receitas

Aplicação web simples em Flask + SQLite para cadastro, login, listagem e CRUD de receitas doces e salgadas.

## Requisitos
- Python 3
- pip

## Como executar localmente
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python init_db.py
python app.py
```

A aplicação ficará disponível em:
- http://127.0.0.1:5000

## Credenciais padrão
- Login: `admin`
- Senha: `admin123`

## Estrutura principal
- `app.py`: aplicação Flask
- `schema.sql`: criação das tabelas
- `seed.sql`: inserts iniciais
- `init_db.py`: cria e popula o banco
- `templates/`: páginas HTML
- `static/style.css`: estilos visuais


## Funcionalidades

- Tela de login
- Listagem de receitas cadastradas
- Cadastro de novas receitas
- Edição de receitas
- Exclusão de receitas
- Banco de dados com receitas e usuário inicial
- Separação de receitas por tipo: doce ou salgada

## Tecnologias utilizadas

- Python 3
- Flask
- SQLite
- HTML
- CSS
- Jinja2
- Docker
- Jenkins

## Pipeline CI/CD

O fluxo esperado do projeto é:

1. Desenvolver no computador local.
2. Enviar as alterações para o GitHub.
3. O Jenkins, em uma máquina virtual acessada via SSH, busca o repositório.
4. O Jenkins instala dependências, executa linter e testes.
5. Se tudo passar, o Jenkins cria a imagem Docker.
6. A aplicação sobe primeiro em homologação.
7. Na branch `main`, a mesma imagem pode ser promovida para produção.

Arquivos criados para esse fluxo:

- `Jenkinsfile`: pipeline com checkout, lint, testes, build Docker, deploy em homologação e deploy em produção.
- `Dockerfile`: imagem da aplicação Flask usando Gunicorn.
- `docker-compose.yml`: serviços `homolog` e `prod` em containers separados.
- `docker-entrypoint.sh`: cria o banco SQLite automaticamente se ele ainda não existir.
- `requirements-dev.txt`: dependências usadas no Jenkins para testes e linter.

## Como rodar com Docker

Build da imagem:
```bash
docker build -t receitas-app:latest .
```

Subir homologação:
```bash
docker-compose up -d homolog
```

A homologação fica disponível em:
- http://localhost:5001

Subir produção:
```bash
docker-compose --profile prod up -d prod
```

A produção fica disponível em:
- http://localhost:5000

## Jenkins na máquina virtual

Na VM, instale:

- Git
- Python 3 e `venv`
- Docker
- Docker Compose
- Jenkins

Depois, crie um job Pipeline no Jenkins apontando para o repositório do GitHub. O Jenkins usará o `Jenkinsfile` automaticamente.

O passo a passo completo para a VM está em `docs/VM_DEPLOY.md`.

## Scripts para apresentação

Os comandos principais da apresentação estão na pasta `scripts/`.

Sequência sugerida para demonstrar do zero na VM:

```bash
cd ~/projeto/receitas-app
scripts/clean_docker_images.sh
scripts/02_run_checks.sh
docker build -t receitas-app:latest .
scripts/03_deploy_homolog.sh
scripts/04_deploy_prod.sh
scripts/05_status.sh
scripts/06_test_urls.sh
```

Para rodar essa sequência automaticamente:

```bash
scripts/07_demo_reset_and_deploy.sh
```

Mais detalhes estão em `scripts/README.md`.

## Estrutura do banco de dados

### Tabela `usuario`
Campos:
- `id`
- `nome`
- `login`
- `senha`
- `situacao`

### Tabela `receita`
Campos:
- `id`
- `nome`
- `descricao`
- `data_registro`
- `custo`
- `tipo_receita`

## Usuário padrão para acesso

Login:
```text
admin
