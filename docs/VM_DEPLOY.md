# Deploy na VM

Esta VM é ambiente de execução. Ela não precisa manter um clone permanente do código-fonte da aplicação.

Ela precisa ter:

- Docker;
- GitHub Actions self-hosted runner;
- pasta `~/receitas-runtime`;
- imagens Docker publicadas no GHCR;
- volumes Docker dos bancos SQLite.

Ambientes:

- Homologação: `http://177.44.248.83:5001`, container `receitas_app_homolog`.
- Produção: `http://177.44.248.83:5000`, container `receitas_app_prod`.

## 1. Preparar a VM pelo PC

Os três scripts principais ficam no seu computador local e acessam a VM por SSH:

```bash
bash scripts/limpar_vm.sh
bash scripts/enviar_vm.sh
bash scripts/iniciar_vm.sh
```

Eles fazem:

- `limpar_vm.sh`: limpa runner, runtime, containers, volumes e imagens do projeto na VM.
- `enviar_vm.sh`: envia apenas `runtime/start.sh` para `~/receitas-runtime`.
- `iniciar_vm.sh`: executa o runtime na VM, recria o runner e sobe homologação/produção.

Para outra VM:

```bash
bash scripts/limpar_vm.sh IP_DA_VM USUARIO
bash scripts/enviar_vm.sh IP_DA_VM USUARIO
bash scripts/iniciar_vm.sh IP_DA_VM USUARIO
```

Para iniciar com uma imagem específica:

```bash
APP_IMAGE=ghcr.io/lucaspfchiesa/receitas-app:SHA_DO_COMMIT bash scripts/iniciar_vm.sh
```

## 2. Preparar a VM manualmente

Entre na VM:

```bash
ssh univates@177.44.248.83
```

Baixe apenas o script de runtime:

```bash
mkdir -p ~/receitas-runtime
curl -fsSL https://raw.githubusercontent.com/LucasPFChiesa/receitas-app/main/runtime/start.sh -o ~/receitas-runtime/start.sh
chmod +x ~/receitas-runtime/start.sh
bash ~/receitas-runtime/start.sh
```

O script pergunta os dados principais. Pode aceitar os padrões:

```text
Dono do repositorio: LucasPFChiesa
Nome do repositorio: receitas-app
Nome do runner: receitas-app-vm
Labels: receitas-app-vm,homologacao,producao
Arquivo do token: /home/univates/keys/github_token.txt
IP publico: 177.44.248.83
```

Ele faz:

1. instala dependências básicas;
2. configura ou recria o runner;
3. gera `~/receitas-runtime/docker-compose.yml`;
4. descobre a imagem mais recente da branch `integracao`;
5. faz `docker pull`;
6. sobe homologação e produção.

## 3. Verificar ambientes

Na VM:

```bash
cd ~/receitas-runtime
docker compose --profile prod ps
```

Testar pelo terminal:

```bash
curl http://localhost:5001/login
curl http://localhost:5000/login
```

Ver a imagem que cada ambiente está usando:

```bash
sudo docker inspect receitas_app_homolog --format '{{.Config.Image}}'
sudo docker inspect receitas_app_prod --format '{{.Config.Image}}'
```

## 4. Fluxo normal

No computador local:

```bash
git add .
git commit -m "Mensagem da alteracao"
git push origin integracao
```

O workflow `CI e Homologacao` roda:

1. linter com `pyflakes`;
2. mess detector com `radon`;
3. testes com `pytest`;
4. build da imagem Docker;
5. publicação no GHCR;
6. atualização automática da homologação.

Produção não muda nesse passo.

## 5. Promover para produção

No GitHub:

```text
Actions -> Promover Integracao para Producao -> Run workflow
```

Depois aprove o ambiente `production` quando o GitHub pedir.

Esse workflow:

1. verifica se `integracao` tem alteração nova;
2. faz merge de `integracao` na `main`;
3. usa a mesma imagem que passou em homologação;
4. atualiza o container `receitas_app_prod`.

## 6. Rollback de produção

Veja a imagem atual ou antiga:

```bash
sudo docker images 'ghcr.io/lucaspfchiesa/receitas-app'
```

No GitHub:

```text
Actions -> Rollback Producao -> Run workflow
```

Preencha `image_sha` com a tag/SHA da imagem para voltar.

## 7. Comandos manuais úteis

Subir os dois ambientes com uma imagem específica:

```bash
cd ~/receitas-runtime
APP_IMAGE=ghcr.io/lucaspfchiesa/receitas-app:SHA_DO_COMMIT bash start.sh --skip-runner --only both
```

Subir só homologação:

```bash
cd ~/receitas-runtime
APP_IMAGE=ghcr.io/lucaspfchiesa/receitas-app:SHA_DO_COMMIT bash start.sh --skip-runner --only homolog
```

Subir só produção:

```bash
cd ~/receitas-runtime
APP_IMAGE=ghcr.io/lucaspfchiesa/receitas-app:SHA_DO_COMMIT bash start.sh --skip-runner --only prod
```

Derrubar os dois ambientes:

```bash
cd ~/receitas-runtime
docker compose --profile prod down
```

Limpar imagens antigas não usadas:

```bash
sudo docker image prune -f
```

## 8. Bancos

Cada ambiente tem seu próprio volume:

```text
homologacao -> receitas-app_homolog_data -> /data/receitas_homolog.db
producao    -> receitas-app_prod_data    -> /data/receitas_prod.db
```

Assim, testar dados em homologação não altera produção.

O banco inteiro e as alterações futuras são controlados por migrations versionadas em:

```text
migrations/
```

Quando homologação ou produção sobem, o entrypoint do container executa `python init_db.py`.
Esse comando aplica as migrations em ordem, cria o banco se ele não existir e aplica somente o que ainda está pendente se o banco já existir.

Migrations atuais:

```text
000_create_schema_inicial.sql -> usuario, receita e dados iniciais
```

Exemplo de fluxo para uma tabela nova:

```bash
touch migrations/001_cria_tabela_exemplo.sql
git add migrations/001_cria_tabela_exemplo.sql
git commit -m "Adiciona migration de exemplo"
git push origin integracao
```

Depois do deploy, a homologação recebe a nova estrutura sem apagar os dados existentes.

## 9. Roteiro da apresentação

1. Mostrar que a VM não tem clone permanente do código-fonte.
2. Rodar o download do `runtime/start.sh`.
3. Executar `bash ~/receitas-runtime/start.sh`.
4. Mostrar homologação em `:5001`.
5. Mostrar produção em `:5000`.
6. Fazer mudança no código local.
7. Commit e push na branch `integracao`.
8. Mostrar `CI e Homologacao` rodando testes, qualidade e build.
9. Mostrar homologação atualizada.
10. Rodar `Promover Integracao para Producao`.
11. Aprovar o ambiente `production`.
12. Mostrar produção atualizada.
