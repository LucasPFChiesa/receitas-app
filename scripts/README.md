# Scripts

Comandos principais para a VM:

```bash
bash scripts/limpar_vm.sh
bash scripts/enviar_vm.sh --token-if-missing
bash scripts/iniciar_vm.sh
```

- `limpar_vm.sh`: limpa runtime, runner, containers, volumes e imagens do projeto na VM.
- `enviar_vm.sh`: envia `runtime/start.sh` para a VM.
- `iniciar_vm.sh`: recria/configura runner e sobe homologação e produção.

O token GitHub nao fica no repositorio. Se ele sumir da VM, envie a copia local de
`~/keys/github_token.txt` assim:

```bash
bash scripts/enviar_vm.sh --token-if-missing
```

Para sobrescrever o token da VM com o token local:

```bash
bash scripts/enviar_vm.sh --token
```

Comandos auxiliares:

- `subir_dev_local.sh`: sobe o ambiente de desenvolvimento local.
- `derrubar_dev_local.sh`: derruba o ambiente de desenvolvimento local.
- `acessar_db_dev.sh`: abre o SQLite do desenvolvimento.
- `acessar_db_homolog.sh`: abre o SQLite da homologação na VM via SSH.
- `acessar_db_producao.sh`: abre o SQLite da produção na VM via SSH.

Você pode abrir o SQLite interativo:

```bash
bash scripts/acessar_db_homolog.sh
```

Ou executar um comando direto:

```bash
bash scripts/acessar_db_homolog.sh '.tables'
bash scripts/acessar_db_homolog.sh 'SELECT * FROM schema_migrations;'
```

Dentro do SQLite, comandos úteis:

```sql
.tables
.schema categoria
SELECT * FROM schema_migrations;
```
