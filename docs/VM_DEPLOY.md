# Deploy na VM

Esta VM concentra os ambientes de execução do desenho:

- Homologação: container `receitas_app_homolog`.
- Produção: container `receitas_app_prod`.

A integração principal fica no GitHub Actions:

- https://github.com/LucasPFChiesa/receitas-app/actions

Dados da VM mostrada:

- IP: `177.44.248.83`
- Usuário SSH: `univates`
- Pasta do projeto: `/home/univates/receitas-app`

## 1. Acessar a VM

```bash
ssh univates@177.44.248.83
cd ~/receitas-app
```

## 2. Preparar VM limpa

Em uma VM limpa, o token do GitHub deve ficar fora da pasta do projeto, no arquivo `~/keys/github_token.txt`. O token precisa ter acesso ao repositório e permissão `Contents: Read and write`.

```bash
mkdir -p ~/keys
nano ~/keys/github_token.txt
chmod 600 ~/keys/github_token.txt
```

Depois execute:

```bash
TOKEN="$(tr -d '\r\n' < ~/keys/github_token.txt)"
curl -fsSL -H "Authorization: Bearer $TOKEN" https://raw.githubusercontent.com/LucasPFChiesa/receitas-app/configurando-com-docker/scripts/preparar_vm.sh -o preparar_vm.sh
chmod +x preparar_vm.sh
./preparar_vm.sh
```

Se o arquivo `preparar_vm.sh` já estiver na VM, basta executar `./preparar_vm.sh`.

Esse script:

- instala Git, Docker e Docker Compose;
- clona a branch `configurando-com-docker`;
- deixa o projeto em `~/receitas-app`;
- prepara as imagens Docker;
- não inicia nenhum container.

A pasta da VM deve ter estes arquivos:

- `Dockerfile`
- `docker-compose.yml`
- `docker-compose.vm.yml`
- `.dockerignore`
- `docker-entrypoint.sh`
- `requirements-dev.txt`
- `scripts/docker-compose.sh`

## 3. Testar homologacao

Na VM:

```bash
cd ~/receitas-app
sh scripts/subir_homologacao.sh
sh scripts/status.sh
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
sh scripts/subir_producao.sh
sh scripts/status.sh
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

Para atualizar homologação manualmente pela VM:

```bash
cd ~/receitas-app
scripts/atualizar_homologacao.sh
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

## 7. Portas usadas

- Homologação: `5001`
- Produção: `5000`

Se a VM tiver firewall ou regra de nuvem, libere essas portas.

## 8. Scripts prontos para apresentacao

Dentro da VM, na pasta do projeto:

```bash
cd ~/receitas-app
```

Limpar Docker como o professor pediu:

```bash
scripts/clean_docker_images.sh
```

Subir homologação:

```bash
scripts/subir_homologacao.sh
```

Subir produção:

```bash
scripts/subir_producao.sh
```

Depois de alterar algo e enviar para o GitHub, atualizar somente homologação:

```bash
scripts/atualizar_homologacao.sh
```

Produção só será atualizada se este comando for executado:

```bash
scripts/atualizar_producao.sh
```

Ver status:

```bash
scripts/status.sh
```
