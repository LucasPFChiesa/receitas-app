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
- Pasta manual do projeto, quando você quiser usar os scripts `.sh`: `/home/univates/receitas-app`

O deploy automático não depende dessa pasta manual. O self-hosted runner baixa o código no workspace interno dele a cada execução do GitHub Actions.

## 1. Acessar a VM

```bash
ssh univates@177.44.248.83
```

## 2. Preparar VM para uso manual

Se a VM tiver o Compose antigo, use `docker-compose` no lugar de `docker compose`.

Para usar os scripts manualmente na VM, instale as dependências, clone o projeto e prepare as imagens:

```bash
sudo apt update
sudo apt install -y git docker.io docker-compose curl
sudo systemctl enable --now docker
git clone --branch configurando-com-docker https://github.com/LucasPFChiesa/receitas-app.git ~/receitas-app
cd ~/receitas-app
APP_IMAGE=receitas-app:manual ./subir_homolog_prod.sh
```

Esses comandos:

- instala Git, Docker e Docker Compose;
- clona a branch `configurando-com-docker`;
- deixa o projeto em `~/receitas-app`;
- cria uma imagem manual e inicia os containers para teste local na VM.

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
- `subir_homolog_prod.sh`
- `derrubar_homolog_prod.sh`

## 3. Testar homologacao

Na VM:

```bash
cd ~/receitas-app
APP_IMAGE=receitas-app:manual ./subir_homolog_prod.sh
sudo docker-compose -f docker-compose.vm.yml ps
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
APP_IMAGE=receitas-app:manual ./subir_homolog_prod.sh
sudo docker-compose -f docker-compose.vm.yml --profile prod ps
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
4. Build Docker da imagem do commit.
5. Publicação da imagem no GHCR com tag igual ao SHA do commit.
6. Atualização automática da homologação, se tudo passar.
7. Atualização da produção somente depois de aprovação manual no GitHub.

Para o deploy pelo GitHub funcionar, a VM deve ter um self-hosted runner do GitHub Actions instalado como serviço. Neste projeto ele usa o nome `receitas-app-vm` e os labels:

```text
self-hosted
receitas-app-vm
homologacao
producao
```

Com isso, o GitHub não precisa abrir SSH para a VM. O próprio runner da VM baixa o commit aprovado e executa Docker localmente.

A imagem usada no deploy tem este formato:

```text
ghcr.io/lucaspfchiesa/receitas-app:SHA_DO_COMMIT
```

Homologação e produção usam a mesma imagem. A produção não reconstrói a aplicação; ela apenas faz `docker pull` da tag do SHA já validado em homologação.

O workflow precisa destas permissões no próprio YAML:

```yaml
permissions:
  contents: read
  packages: write
```

Se o pacote do GHCR ficar privado, confirme no GitHub que o repositório tem acesso ao pacote:

```text
GitHub -> Packages -> receitas-app -> Package settings -> Manage Actions access
```

Também configure o ambiente `production` no GitHub com aprovação obrigatória:

```text
Settings -> Environments -> New environment -> production
```

Depois, em `production`, configure:

```text
Settings -> Environments -> production -> Required reviewers
```

Adicione o usuário que deve aprovar. Sem essa configuração, o job de produção pode iniciar automaticamente.

O deploy automático do GitHub não depende de scripts `.sh`; o self-hosted runner da VM baixa a imagem exata do commit no GHCR e atualiza o container localmente.

O fluxo fica assim:

```text
git push
  -> CI e Homologacao roda linter, mess detector, testes e build Docker
  -> se passar, o runner receitas-app-vm atualiza homologacao automaticamente
  -> Deploy Producao inicia depois da CI e Homologacao concluida com sucesso
  -> Deploy Producao fica aguardando aprovacao no ambiente production
  -> depois da aprovacao, o runner receitas-app-vm atualiza o container de producao
```

## 6. Verificar SHA em cada ambiente

Na VM:

```bash
sudo docker inspect receitas_app_homolog --format '{{.Config.Image}}'
sudo docker inspect receitas_app_prod --format '{{.Config.Image}}'
```

Exemplo esperado:

```text
ghcr.io/lucaspfchiesa/receitas-app:12812da...
```

Ver status:

```bash
sudo docker-compose -f docker-compose.vm.yml --profile prod ps
```

Testar HTTP:

```bash
curl http://localhost:5001/login
curl http://localhost:5000/login
```

Para atualizar homologação manualmente pela VM:

```bash
cd ~/receitas-app
APP_IMAGE=ghcr.io/lucaspfchiesa/receitas-app:SHA_DO_COMMIT ./subir_homolog_prod.sh
```

## 7. Resultado esperado

O GitHub Actions deve executar:

1. Buscar código no GitHub.
2. Criar ambiente Python.
3. Instalar `requirements-dev.txt`.
4. Rodar `pyflakes`.
5. Rodar `radon` como mess detector.
6. Rodar `pytest`.
7. Publicar a imagem Docker `ghcr.io/lucaspfchiesa/receitas-app:SHA_DO_COMMIT`.
8. Atualizar homologação automaticamente com essa imagem.
9. Validar HTTP de homologação.
10. Aguardar aprovação no ambiente `production`.
11. Atualizar produção com a mesma imagem se a aprovação for liberada.
12. Validar HTTP de produção.

## 8. Portas usadas

- Desenvolvimento local: `5002`
- Homologação: `5001`
- Produção: `5000`

Se a VM tiver firewall ou regra de nuvem, libere essas portas.

## 9. Bancos separados

Cada ambiente usa seu próprio arquivo SQLite dentro de seu próprio volume Docker:

```text
dev        -> dev_data       -> /data/receitas_dev.db
homolog    -> homolog_data   -> /data/receitas_homolog.db
prod       -> prod_data      -> /data/receitas_prod.db
```

Com isso, um cadastro feito em desenvolvimento não aparece em homologação, e um teste feito em homologação não altera a produção.

## 10. Comandos prontos para apresentacao

Dicas antes da apresentacao:

```bash
cd ~/receitas-app
sudo docker-compose -f docker-compose.vm.yml --profile prod down
sudo docker image prune -f
```

Esse comando derruba os containers e limpa imagens não usadas.

Dentro da VM, na pasta do projeto:

```bash
cd ~/receitas-app
```

Limpar Docker como o professor pediu:

```bash
sudo docker-compose -f docker-compose.vm.yml --profile prod down
sudo docker image prune -f
```

Se o professor pedir limpeza total da demonstração, removendo também os volumes:

```bash
sudo docker-compose -f docker-compose.vm.yml --profile prod down -v
sudo docker image rm $(sudo docker images 'ghcr.io/lucaspfchiesa/receitas-app' -q) || true
```

Essa limpeza apaga os bancos dos volumes `homolog_data` e `prod_data`. Use somente quando isso for solicitado.

Subir homologação:

```bash
APP_IMAGE=ghcr.io/lucaspfchiesa/receitas-app:SHA_DO_COMMIT sudo docker-compose -f docker-compose.vm.yml up -d homolog
```

Subir produção:

```bash
APP_IMAGE=ghcr.io/lucaspfchiesa/receitas-app:SHA_DO_COMMIT sudo docker-compose -f docker-compose.vm.yml --profile prod up -d prod
```

Depois de alterar algo e enviar para o GitHub, atualizar somente homologação:

```bash
git push
```

Produção só será atualizada se este comando for executado manualmente ou se o job `production` for aprovado no GitHub:

```bash
APP_IMAGE=ghcr.io/lucaspfchiesa/receitas-app:SHA_DO_COMMIT sudo docker-compose -f docker-compose.vm.yml --profile prod up -d prod
```

Ver status:

```bash
docker compose -f docker-compose.vm.yml --profile prod ps
```

Subir homologação e produção juntos:

```bash
./subir_homolog_prod.sh
```

Para usar uma imagem especifica ja publicada no GHCR:

```bash
APP_IMAGE=ghcr.io/lucaspfchiesa/receitas-app:SHA_DO_COMMIT ./subir_homolog_prod.sh
```

Limpar imagens antigas do projeto sem apagar imagens em uso:

```bash
./clean_docker_images.sh
```

Depois da limpeza, para reconstruir tudo pela automação:

```bash
git push
```

O runner da VM recebe o job, baixa o código no workspace interno, faz pull da imagem do SHA e recria os containers.
Se você não tiver alteração nova para commitar, também pode entrar em `Actions -> CI e Homologacao`, escolher uma execução/branch e usar `Re-run all jobs`.

## 11. Rollback de producao

O rollback usa o workflow manual:

```text
Actions -> Rollback Producao -> Run workflow
```

Informe o `image_sha` desejado, por exemplo:

```text
12812da...
```

O workflow faz:

- `docker pull ghcr.io/lucaspfchiesa/receitas-app:SHA`;
- atualiza somente o container `receitas_app_prod`;
- preserva o volume `prod_data`;
- verifica `http://127.0.0.1:5000/login`.

Derrubar homologação e produção juntos:

```bash
./derrubar_homolog_prod.sh
```

Desconectar o runner da VM do GitHub Actions:

```bash
./desconectar_runner_vm.sh
```

Conectar o runner da VM novamente:

```bash
./conectar_runner_vm.sh
```

Ver status do runner:

```bash
./status_runner_vm.sh
```

Para usar outra VM rapidamente, passe IP e usuário:

```bash
./conectar_runner_vm.sh 177.44.248.83 univates
./desconectar_runner_vm.sh 177.44.248.83 univates
./status_runner_vm.sh 177.44.248.83 univates
```

Também é possível usar variáveis:

```bash
VM_HOST=177.44.248.83 VM_USER=univates ./conectar_runner_vm.sh
```
