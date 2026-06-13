# Sistema de Receitas

Aplicação web simples em Flask + SQLite para cadastro, login, listagem e CRUD de receitas doces e salgadas.

## Requisitos
- Docker
- Docker Compose

## Como executar localmente
```bash
sh scripts/docker-compose.sh up -d dev
```

A aplicação ficará disponível em:
- http://localhost:5002

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
- Integração com GitHub Actions

## Fluxo do Projeto

Fluxo usado no trabalho:

1. Desenvolver no computador local.
2. Enviar as alterações para o GitHub.
3. A integração, usando GitHub Actions, valida o repositório no GitHub.
4. A integração instala dependências, executa linter, mess detector e testes.
5. Se tudo passar, a integração valida o build Docker.
6. A VM é preparada com um script único.
7. Homologação e produção são iniciadas por scripts separados.

Arquivos principais desse fluxo:

- `.github/workflows/integracao.yml`: pipeline com linter, mess detector e testes.
- `Dockerfile`: imagem da aplicação Flask usando Gunicorn.
- `docker-compose.yml`: ambiente de desenvolvimento local.
- `docker-compose.vm.yml`: ambientes de homologação e produção na VM.
- `docker-entrypoint.sh`: cria o banco SQLite automaticamente se ele ainda não existir.
- `requirements-dev.txt`: dependências usadas na integração para testes, linter e mess detector.

## Como rodar com Docker

Ambiente de desenvolvimento no seu PC:
```bash
sh scripts/docker-compose.sh up -d dev
```

A aplicação de desenvolvimento fica disponível em:
- http://localhost:5002

Você continua editando os arquivos normalmente no VS Code. O container `dev` usa volume `.:/app`, então as alterações feitas no PC aparecem dentro do container.

Homologação e produção não são executadas no PC. Elas usam `docker-compose.vm.yml` e ficam apenas na VM.

## Integração

A integração roda no GitHub Actions sempre que houver `push` ou `pull_request`.

Ela executa:

- Linter com `pyflakes`
- Mess detector com `radon`
- Testes com `pytest`
- Build Docker

Página da integração:

- https://github.com/LucasPFChiesa/receitas-app/actions

O passo a passo completo para a VM está em `docs/VM_DEPLOY.md`.

## Scripts da VM

Os comandos principais ficam na pasta `scripts/`.

```bash
cd ~/receitas-app
```

Preparar uma VM limpa:

```bash
mkdir -p ~/keys
printf "Token GitHub: "
stty -echo
read -r GITHUB_TOKEN
stty echo
printf "\n"
printf "%s\n" "$GITHUB_TOKEN" > ~/keys/github_token.txt
chmod 600 ~/keys/github_token.txt
curl -fsSL -H "Authorization: Bearer $GITHUB_TOKEN" https://raw.githubusercontent.com/LucasPFChiesa/receitas-app/configurando-com-docker/scripts/preparar_vm.sh -o preparar_vm.sh
chmod +x preparar_vm.sh
GITHUB_TOKEN="$GITHUB_TOKEN" ./preparar_vm.sh
```

Limpar Docker:

```bash
scripts/clean_docker_images.sh
```

Subir ambientes:

```bash
scripts/subir_homologacao.sh
scripts/subir_producao.sh
scripts/status.sh
```

Se o professor pedir para alterar um caractere, o fluxo principal é fazer commit e push. A integração roda no GitHub e a homologação é atualizada automaticamente.

Para atualizar homologação manualmente pela VM:

```bash
scripts/atualizar_homologacao.sh
```

A produção só muda pelo workflow manual do GitHub Actions ou pelo script `scripts/atualizar_producao.sh`.

Para derrubar os ambientes:

```bash
scripts/derrubar_homologacao.sh
scripts/derrubar_producao.sh
```

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
