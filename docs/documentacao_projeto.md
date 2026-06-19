# Sistema de Receitas

## Visão geral

Aplicação web em Flask com SQLite para cadastro, consulta, edição, exclusão, filtros e exportação em PDF de receitas.

O projeto separa três ambientes:

- Desenvolvimento no computador local.
- Homologação na máquina virtual.
- Produção na máquina virtual.

## Arquitetura

```text
Computador local
  |
  | commit e push na branch integracao
  v
GitHub Actions
  |
  | linter, mess detector, testes e build Docker
  v
GHCR
  |
  | imagem ghcr.io/lucaspfchiesa/receitas-app:SHA
  v
VM 177.44.248.83
  |
  | runner + Docker + ~/receitas-runtime
  v
homologacao e producao
```

A VM não mantém clone permanente do código-fonte. Ela executa imagens Docker publicadas no GHCR.

## Ambientes

### Desenvolvimento

Roda no computador local:

```bash
docker compose up -d --build dev
```

URL:

```text
http://localhost:5002
```

### Homologação

Roda na VM:

```text
http://177.44.248.83:5001
```

Container:

```text
receitas_app_homolog
```

### Produção

Roda na VM:

```text
http://177.44.248.83:5000
```

Container:

```text
receitas_app_prod
```

## Bancos separados

Cada ambiente usa seu próprio volume Docker:

```text
dev        -> dev_data
homolog    -> receitas-app_homolog_data
prod       -> receitas-app_prod_data
```

Arquivos dentro dos containers:

```text
dev        -> /data/receitas_dev.db
homolog    -> /data/receitas_homolog.db
prod       -> /data/receitas_prod.db
```

## Integração

Workflow:

```text
.github/workflows/integracao.yml
```

Ele roda em push na branch `integracao`:

1. instala dependências;
2. executa `pyflakes`;
3. executa `radon`;
4. executa `pytest`;
5. gera a imagem Docker;
6. publica no GHCR;
7. atualiza homologação automaticamente.

Produção não muda nesse workflow.

## Promoção para produção

Workflow:

```text
.github/workflows/promover-producao.yml
```

Uso:

```text
Actions -> Promover Integracao para Producao -> Run workflow
```

Depois é necessário aprovar o ambiente `production`.

Esse workflow faz merge de `integracao` na `main` e atualiza produção com a mesma imagem já validada em homologação.

## Rollback

Workflow:

```text
.github/workflows/rollback-producao.yml
```

Uso:

```text
Actions -> Rollback Producao -> Run workflow
```

Informe o SHA/tag da imagem Docker para voltar a produção.

## Preparação da VM

Na VM:

```bash
mkdir -p ~/receitas-runtime
curl -fsSL https://raw.githubusercontent.com/LucasPFChiesa/receitas-app/main/runtime/start.sh -o ~/receitas-runtime/start.sh
chmod +x ~/receitas-runtime/start.sh
bash ~/receitas-runtime/start.sh
```

O script prepara runner, Docker Compose runtime, homologação e produção.

## Estrutura principal

```text
app.py                         aplicação Flask
schema.sql                     estrutura do banco
seed.sql                       dados iniciais
init_db.py                     criação do banco
Dockerfile                     imagem da aplicação
docker-compose.yml             ambiente local de desenvolvimento
runtime/start.sh               preparação e deploy runtime da VM
requirements.txt               dependências da aplicação
requirements-dev.txt           dependências da integração
templates/                     páginas HTML
static/                        CSS
tests/                         testes automatizados
.github/workflows/             GitHub Actions
```

## Acesso padrão

```text
login: admin
senha: admin123
```
