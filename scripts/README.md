# Scripts

Comandos principais para a VM:

```bash
bash scripts/limpar_vm.sh
bash scripts/enviar_vm.sh
bash scripts/iniciar_vm.sh
```

- `limpar_vm.sh`: limpa runtime, runner, containers, volumes e imagens do projeto na VM.
- `enviar_vm.sh`: envia somente `runtime/start.sh` para a VM.
- `iniciar_vm.sh`: recria/configura runner e sobe homologação e produção.

Comandos auxiliares:

- `subir_dev_local.sh`: sobe o ambiente de desenvolvimento local.
- `derrubar_dev_local.sh`: derruba o ambiente de desenvolvimento local.
- `acessar_db_dev.sh`: abre o SQLite do desenvolvimento.
- `acessar_db_homolog.sh`: abre o SQLite da homologação.
- `acessar_db_producao.sh`: abre o SQLite da produção.
