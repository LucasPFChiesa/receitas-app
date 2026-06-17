# Sistema de Receitas

## Visão geral

Aplicação web em Flask com SQLite para cadastro, consulta, edição, exclusão, filtros e exportação em PDF de receitas.

O projeto usa containers Docker para separar os ambientes:

- Desenvolvimento no computador local.
- Homologação na máquina virtual.
- Produção na máquina virtual.

## Arquitetura

```text
Computador local
  |
  | commit e push
  v
GitHub
  |
  | GitHub Actions
  | - linter
  | - mess detector
  | - testes
  | - build Docker
  v
VM 177.44.248.83
  |
  | containers
  | - homologacao
  | - producao
```

## Ambientes

### Desenvolvimento

Roda apenas no computador local.

Arquivo:

```text
docker-compose.yml
```

Serviço:

```text
dev
```

URL:

```text
http://localhost:5002
```

### Homologação

Roda apenas na VM.

Arquivo:

```text
docker-compose.vm.yml
```

Serviço:

```text
homolog
```

URL:

```text
http://177.44.248.83:5001
```

### Produção

Roda apenas na VM.

Arquivo:

```text
docker-compose.vm.yml
```

Serviço:

```text
prod
```

URL:

```text
http://177.44.248.83:5000
```

## Bancos separados

Cada ambiente usa um volume Docker próprio:

```text
dev        -> dev_data       -> /data/receitas_dev.db
homolog    -> homolog_data   -> /data/receitas_homolog.db
prod       -> prod_data      -> /data/receitas_prod.db
```

Assim, dados cadastrados em desenvolvimento ou homologação não alteram o banco da produção.

## Integração

A integração roda no GitHub Actions.

Arquivo:

```text
.github/workflows/integracao.yml
```

Etapas:

1. Instala dependências.
2. Executa linter com `pyflakes`.
3. Executa mess detector com `radon`.
4. Executa testes com `pytest`.
5. Valida o build Docker.
6. Atualiza homologação automaticamente.
7. Aguarda aprovação manual para atualizar produção.

Na VM, a preparação inicial é feita com comandos Docker e Git. Depois disso, homologação e produção podem ser controladas manualmente com `docker compose`.

Produção só é atualizada quando o job do ambiente `production` for aprovado no GitHub, ou quando o comando de produção for executado manualmente na VM.

## Fluxo de uso

Se a máquina tiver o Compose antigo, use `docker-compose` no lugar de `docker compose`.

Desenvolvimento local:

```bash
docker compose up -d --build dev
```

Enviar alterações:

```bash
git add .
git commit -m "Mensagem da alteracao"
git push
```

Após o push, o GitHub Actions valida o projeto.

Na VM limpa, prepare o projeto com Docker e Git:

```bash
git clone --branch integracao https://github.com/LucasPFChiesa/receitas-app.git ~/receitas-app
cd ~/receitas-app
./scripts/start.sh
```

Depois, suba homologação ou produção com uma imagem manual ou com uma imagem ja publicada no GHCR.

Para o deploy automático funcionar pelo GitHub Actions, a VM possui um self-hosted runner instalado como serviço com o label `receitas-app-vm`.

Com isso, os jobs de deploy rodam dentro da própria VM e executam Docker localmente. O ambiente `production` deve ter aprovação obrigatória em `Settings -> Environments`.

O deploy automático não chama scripts de atualização; o runner da VM baixa a imagem do commit aprovada no GHCR e executa Docker diretamente na VM.

## Comandos principais

```bash
docker compose up -d --build dev
```

Na VM, homologação e produção usam uma imagem ja publicada no GHCR:

```bash
APP_IMAGE=ghcr.io/lucaspfchiesa/receitas-app:SHA_DO_COMMIT sudo docker-compose -f docker-compose.vm.yml up -d homolog
APP_IMAGE=ghcr.io/lucaspfchiesa/receitas-app:SHA_DO_COMMIT sudo docker-compose -f docker-compose.vm.yml --profile prod up -d prod
docker compose -f docker-compose.vm.yml --profile prod ps
```

## Estrutura principal

```text
app.py                         aplicação Flask
schema.sql                     estrutura do banco
seed.sql                       dados iniciais
init_db.py                     criação do banco
Dockerfile                     imagem da aplicação
docker-compose.yml             ambiente local
docker-compose.vm.yml          ambientes da VM
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
