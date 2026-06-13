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

## 2. Instalar dependências da VM

Execute na VM:

```bash
sudo apt update
sudo apt install -y git docker.io docker-compose curl
sudo systemctl enable --now docker
sudo usermod -aG docker univates
```

Depois saia e entre novamente no SSH para o grupo `docker` valer:

```bash
exit
ssh univates@177.44.248.83
```

Teste:

```bash
docker --version
docker-compose --version
```

## 3. Enviar o projeto para a VM

O projeto pode ser copiado direto do PC para a VM. Na VM, o caminho usado será:

```bash
~/receitas-app
```

A pasta da VM deve ter estes arquivos:

- `Dockerfile`
- `docker-compose.yml`
- `docker-compose.vm.yml`
- `.dockerignore`
- `docker-entrypoint.sh`
- `requirements-dev.txt`
- `scripts/docker-compose.sh`

## 4. Testar homologacao manualmente

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

## 5. Testar producao manualmente

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

## 6. Integração no GitHub Actions

A integração roda automaticamente no GitHub quando você envia código:

```bash
git push
```

Ela executa:

1. Linter com `pyflakes`.
2. Mess detector com `radon`.
3. Testes com `pytest`.

Depois de a integração passar, atualize a homologação na VM:

```bash
cd ~/receitas-app
scripts/atualizar_homologacao.sh
```

## 7. Resultado esperado

O GitHub Actions deve executar:

1. Buscar código no GitHub.
2. Criar ambiente Python.
3. Instalar `requirements-dev.txt`.
4. Rodar `pyflakes`.
5. Rodar `radon` como mess detector.
6. Rodar `pytest`.
7. Validar o build da imagem Docker.
8. Liberar o código para ser atualizado em homologação.

## 8. Portas usadas

- Homologação: `5001`
- Produção: `5000`

Se a VM tiver firewall ou regra de nuvem, libere essas portas.

## 9. Scripts prontos para apresentacao

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
