# Sistema de Receitas

Aplicação web simples em Flask + SQLite para cadastro, login, listagem e CRUD de receitas doces e salgadas.

## Requisitos
- Docker
- Docker Compose

## Como executar localmente
```bash
docker compose up -d --build dev
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
5. Se tudo passar, a integração constrói e publica uma imagem Docker com a tag do SHA do commit.
6. Se tudo passar, o runner da VM atualiza a homologação automaticamente com essa imagem.
7. Produção fica aguardando aprovação manual no GitHub.
8. Depois da aprovação, produção usa a mesma imagem que passou em homologação.

Arquivos principais desse fluxo:

- `.github/workflows/integracao.yml`: pipeline com linter, mess detector e testes.
- `.github/workflows/promover-producao.yml`: botão manual para promover a integração aprovada para produção.
- `.github/workflows/rollback-producao.yml`: botão manual para voltar a produção para uma imagem anterior.
- `Dockerfile`: imagem da aplicação Flask usando Gunicorn.
- `docker-compose.yml`: ambiente de desenvolvimento local.
- `runtime/start.sh`: prepara a VM, configura o runner e sobe homologação/produção sem clone permanente do código.
- `scripts/docker-entrypoint.sh`: cria o banco SQLite automaticamente se ele ainda não existir.
- `requirements-dev.txt`: dependências usadas na integração para testes, linter e mess detector.

## Como rodar com Docker

Se sua máquina tiver o Compose antigo, use `docker-compose` no lugar de `docker compose`.

Ambiente de desenvolvimento no seu PC:
```bash
docker compose up -d --build dev
```

A aplicação de desenvolvimento fica disponível em:
- http://localhost:5002

Você continua editando os arquivos normalmente no VS Code. O container `receitas_app_dev` usa volume `.:/app`, então as alterações feitas no PC aparecem dentro do container.

Homologação e produção não são executadas no PC. Elas rodam na VM a partir da imagem publicada no GHCR e do compose gerado em `~/receitas-runtime`.

Cada ambiente usa um banco separado:

```text
dev        -> /data/receitas_dev.db
homolog    -> /data/receitas_homolog.db
prod       -> /data/receitas_prod.db
```

## Integração

A integração roda no GitHub Actions sempre que houver `push` ou `pull_request`.

Ela executa:

- Linter com `pyflakes`
- Mess detector com `radon`
- Testes com `pytest`
- Build Docker
- Publicação da imagem do commit no GHCR
- Deploy automático em homologação
- Promoção manual da integração para produção, com aprovação no ambiente `production`

Página da integração:

- https://github.com/LucasPFChiesa/receitas-app/actions

O deploy roda em um GitHub Actions self-hosted runner instalado na VM com o label `receitas-app-vm`. Assim, o GitHub não precisa abrir SSH para a VM; a própria VM executa o Docker localmente.

Para produção ter botão de aprovação, configure o ambiente `production` em `Settings -> Environments` com revisor obrigatório.

O deploy automático não mantém clone permanente do código-fonte na VM. A VM usa apenas Docker, runner, `~/receitas-runtime` e a imagem do commit no GHCR. Homologação e produção usam a mesma imagem:

```text
ghcr.io/lucaspfchiesa/receitas-app:SHA_DO_COMMIT
```

Para produção realmente aguardar aprovação, configure:

```text
Settings -> Environments -> production -> Required reviewers
```

O passo a passo completo para a VM está em `docs/VM_DEPLOY.md`.

## Roteiro rapido da apresentacao

No PC, subir desenvolvimento:

```bash
docker compose up -d --build dev
```

Depois de alterar algo no projeto, enviar para o GitHub:

```bash
git add .
git commit -m "Ajusta detalhe da apresentacao"
git push
```

Na VM limpa, usando os scripts do seu PC:

```bash
bash scripts/limpar_vm.sh
bash scripts/enviar_vm.sh
bash scripts/iniciar_vm.sh
```

Depois da preparacao, o próprio script já sobe os dois ambientes. Para trocar a imagem manualmente a partir do PC:

```bash
APP_IMAGE=ghcr.io/lucaspfchiesa/receitas-app:SHA_DO_COMMIT bash scripts/iniciar_vm.sh
```

Atualizar depois de um novo push:

```bash
git push
```

## Scripts principais da VM

Estes comandos são executados no seu PC e controlam a VM por SSH:

```bash
bash scripts/limpar_vm.sh
bash scripts/enviar_vm.sh
bash scripts/iniciar_vm.sh
```

Função de cada um:

- `scripts/limpar_vm.sh`: remove runner, runtime, containers, volumes e imagens deste projeto na VM.
- `scripts/enviar_vm.sh`: envia somente `runtime/start.sh` para `~/receitas-runtime` na VM.
- `scripts/iniciar_vm.sh`: executa o runtime na VM, recria runner e sobe homologação/produção.

Para usar outro IP:

```bash
bash scripts/limpar_vm.sh IP_DA_VM USUARIO
bash scripts/enviar_vm.sh IP_DA_VM USUARIO
bash scripts/iniciar_vm.sh IP_DA_VM USUARIO
```

Para iniciar com uma imagem específica:

```bash
APP_IMAGE=ghcr.io/lucaspfchiesa/receitas-app:SHA_DO_COMMIT bash scripts/iniciar_vm.sh
```

## Comandos diretos na VM

```bash
cd ~/receitas-runtime
```

Preparar uma VM limpa:

```bash
mkdir -p ~/receitas-runtime
curl -fsSL https://raw.githubusercontent.com/LucasPFChiesa/receitas-app/main/runtime/start.sh -o ~/receitas-runtime/start.sh
chmod +x ~/receitas-runtime/start.sh
bash ~/receitas-runtime/start.sh
```

Limpar Docker:

```bash
docker compose --profile prod down
docker image prune -f
```

Subir ambientes:

```bash
APP_IMAGE=ghcr.io/lucaspfchiesa/receitas-app:SHA_DO_COMMIT bash start.sh --skip-runner --only both
docker compose --profile prod ps
```

Se o professor pedir para alterar um caractere, o fluxo principal é fazer commit e push. A integração roda no GitHub e atualiza homologação automaticamente se tudo passar.

Para atualizar homologação manualmente pela VM:

```bash
APP_IMAGE=ghcr.io/lucaspfchiesa/receitas-app:SHA_DO_COMMIT bash ~/receitas-runtime/start.sh --skip-runner --only homolog
```

A produção só muda quando você roda o workflow `Promover Integracao para Producao` no GitHub e aprova o ambiente `production`, ou quando o comando de produção for executado manualmente na VM.

Para derrubar os ambientes:

```bash
cd ~/receitas-runtime
docker compose --profile prod stop homolog prod
```

Para verificar qual imagem está rodando:

```bash
sudo docker inspect receitas_app_homolog --format '{{.Config.Image}}'
sudo docker inspect receitas_app_prod --format '{{.Config.Image}}'
```

Rollback de produção:

```text
Actions -> Rollback Producao -> Run workflow -> image_sha
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
