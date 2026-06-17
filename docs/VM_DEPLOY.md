# Deploy na VM

Esta VM concentra os ambientes de execução do desenho:

- Homologação: container `receitas_app_homolog`.
- Produção: container `receitas_app_prod`.

O desenvolvimento roda em outro container, no computador local:

- Desenvolvimento: container `receitas_app_dev`.

A integração principal fica no GitHub Actions:

- https://github.com/LucasPFChiesa/receitas-app/actions

Dados da VM mostrada:

- IP: `177.44.248.83`
- Usuário SSH: `univates`
- Pasta do projeto: `/home/univates/receitas-app`

## 1. Acessar a VM

```bash
ssh univates@177.44.248.83
```

## 2. Preparar VM limpa

Se a VM tiver o Compose antigo, use `docker-compose` no lugar de `docker compose`.

Em uma VM limpa, instale as dependências, clone o projeto e prepare as imagens:

```bash
sudo apt update
sudo apt install -y git docker.io docker-compose curl
sudo systemctl enable --now docker
git clone --branch configurando-com-docker https://github.com/LucasPFChiesa/receitas-app.git ~/receitas-app
cd ~/receitas-app
docker compose -f docker-compose.vm.yml build homolog prod
```

Esses comandos:

- instala Git, Docker e Docker Compose;
- clona a branch `configurando-com-docker`;
- deixa o projeto em `~/receitas-app`;
- prepara as imagens Docker;
- não inicia nenhum container.

Depois da preparação, entre na pasta:

```bash
cd ~/receitas-app
```

A pasta da VM deve ter estes arquivos:

- `Dockerfile`
- `docker-compose.yml`
- `docker-compose.vm.yml`
- `.dockerignore`
- `docker-entrypoint.sh`
- `requirements-dev.txt`
- `subir_vm.sh`
- `derrubar_vm.sh`

## 3. Testar homologacao

Na VM:

```bash
cd ~/receitas-app
docker compose -f docker-compose.vm.yml up -d --build homolog
docker compose -f docker-compose.vm.yml ps
```

Homologação:

```text
http://177.44.248.83:5001
```

Teste pelo terminal da VM:

```bash
curl http://localhost:5001/login
```

## 4. Testar producao

Na VM:

```bash
cd ~/receitas-app
docker compose -f docker-compose.vm.yml --profile prod up -d --build prod
docker compose -f docker-compose.vm.yml --profile prod ps
```

Produção:

```text
http://177.44.248.83:5000
```

## 5. Integração no GitHub Actions

A integração roda automaticamente no GitHub quando você envia código:

```bash
git push
```

Ela executa:

1. Linter com `pyflakes`.
2. Mess detector com `radon`.
3. Testes com `pytest`.
4. Build Docker.
5. Atualização automática da homologação, se tudo passar.
6. Atualização da produção somente depois de aprovação manual no GitHub.

Para o deploy pelo GitHub funcionar, cadastre estes secrets no repositório:

```text
VM_HOST      -> 177.44.248.83
VM_USER      -> univates
VM_SSH_KEY   -> chave privada SSH que acessa a VM
```

O arquivo `~/keys/github_token.txt` deve existir na VM. Ele é usado pela própria VM para fazer `git fetch` autenticado no GitHub. Ele não substitui o secret `VM_SSH_KEY`, porque o GitHub Actions ainda precisa de uma chave SSH para abrir a conexão com a VM.

Também configure o ambiente `production` no GitHub com aprovação obrigatória:

```text
Settings -> Environments -> New environment -> production
```

Depois, em `production`, adicione um revisor obrigatório. Assim o job de produção fica parado no GitHub até alguém clicar em aprovar.

O deploy automático do GitHub não depende de scripts `.sh`; ele acessa a VM por SSH, busca a branch e faz checkout do commit exato do workflow antes de atualizar o container.

O fluxo fica assim:

```text
git push
  -> CI e Homologacao roda linter, mess detector, testes e build Docker
  -> se passar, CI e Homologacao atualiza homologacao automaticamente
  -> Deploy Producao inicia depois da CI e Homologacao concluida com sucesso
  -> Deploy Producao fica aguardando aprovacao no ambiente production
  -> depois da aprovacao, Deploy Producao atualiza o container de producao
```

Para atualizar homologação manualmente pela VM:

```bash
cd ~/receitas-app
git pull
docker compose -f docker-compose.vm.yml up -d --build homolog
```

## 6. Resultado esperado

O GitHub Actions deve executar:

1. Buscar código no GitHub.
2. Criar ambiente Python.
3. Instalar `requirements-dev.txt`.
4. Rodar `pyflakes`.
5. Rodar `radon` como mess detector.
6. Rodar `pytest`.
7. Validar o build da imagem Docker.
8. Atualizar homologação automaticamente.
9. Aguardar aprovação no ambiente `production`.
10. Atualizar produção se a aprovação for liberada.

## 7. Portas usadas

- Desenvolvimento local: `5002`
- Homologação: `5001`
- Produção: `5000`

Se a VM tiver firewall ou regra de nuvem, libere essas portas.

## 8. Bancos separados

Cada ambiente usa seu próprio arquivo SQLite dentro de seu próprio volume Docker:

```text
dev        -> dev_data       -> /data/receitas_dev.db
homolog    -> homolog_data   -> /data/receitas_homolog.db
prod       -> prod_data      -> /data/receitas_prod.db
```

Com isso, um cadastro feito em desenvolvimento não aparece em homologação, e um teste feito em homologação não altera a produção.

## 9. Comandos prontos para apresentacao

Dicas antes da apresentacao:

```bash
cd ~/receitas-app
docker compose -f docker-compose.vm.yml --profile prod down
docker image prune -f
```

Esse comando derruba os containers e limpa imagens não usadas.

Dentro da VM, na pasta do projeto:

```bash
cd ~/receitas-app
```

Limpar Docker como o professor pediu:

```bash
docker compose -f docker-compose.vm.yml --profile prod down
docker image prune -f
```

Subir homologação:

```bash
docker compose -f docker-compose.vm.yml up -d --build homolog
```

Subir produção:

```bash
docker compose -f docker-compose.vm.yml --profile prod up -d --build prod
```

Depois de alterar algo e enviar para o GitHub, atualizar somente homologação:

```bash
git pull
docker compose -f docker-compose.vm.yml up -d --build homolog
```

Produção só será atualizada se este comando for executado manualmente ou se o job `production` for aprovado no GitHub:

```bash
git pull
docker compose -f docker-compose.vm.yml --profile prod up -d --build prod
```

Ver status:

```bash
docker compose -f docker-compose.vm.yml --profile prod ps
```

Subir homologação e produção juntos:

```bash
./subir_vm.sh
```

Derrubar homologação e produção juntos:

```bash
./derrubar_vm.sh
```
