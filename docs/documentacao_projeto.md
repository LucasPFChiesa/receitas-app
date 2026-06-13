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
dev        -> dev_data
homolog    -> homolog_data
prod       -> prod_data
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

Na VM, a preparação inicial é feita por um script único. Depois disso, homologação e produção são controladas por scripts separados.

Produção é atualizada apenas por execução manual do workflow no GitHub Actions.

## Fluxo de uso

Desenvolvimento local:

```bash
sh scripts/docker-compose.sh up -d dev
```

Enviar alterações:

```bash
git add .
git commit -m "Mensagem da alteracao"
git push
```

Após o push, o GitHub Actions valida o projeto.

Na VM limpa, preparar o projeto:

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

Depois, subir homologação ou produção com os scripts próprios.

## Scripts da VM

```bash
scripts/subir_homologacao.sh
scripts/atualizar_homologacao.sh
scripts/derrubar_homologacao.sh
scripts/subir_producao.sh
scripts/atualizar_producao.sh
scripts/derrubar_producao.sh
scripts/status.sh
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
scripts/                       scripts operacionais
.github/workflows/             GitHub Actions
```

## Acesso padrão

```text
login: admin
senha: admin123
```
