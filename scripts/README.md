# Scripts de apresentacao

Rode estes comandos dentro da pasta do projeto na VM:

```bash
cd ~/projeto/receitas-app
```

Scripts principais:

- `scripts/00_dev_up.sh`: sobe o container de desenvolvimento no PC em `localhost:5002`.
- `scripts/00_dev_down.sh`: para o container de desenvolvimento.
- `scripts/00_dev_logs.sh`: mostra os logs do container de desenvolvimento.
- `scripts/00_dev_shell.sh`: abre um terminal dentro do container de desenvolvimento.
- `scripts/clean_docker_images.sh`: limpa containers, imagens, volumes nao usados e cache Docker.
- `scripts/01_prepare_vm.sh`: instala Docker, Docker Compose, Java e Jenkins.
- `scripts/02_run_checks.sh`: roda lint e testes.
- `scripts/02_run_checks_docker.sh`: roda lint, mess detector e testes dentro de container Docker.
- `scripts/03_deploy_homolog.sh`: sobe homologacao em `5001`.
- `scripts/04_deploy_prod.sh`: sobe producao em `5000`.
- `scripts/05_status.sh`: mostra containers, imagens e URLs.
- `scripts/06_test_urls.sh`: testa Jenkins, homologacao e producao.
- `scripts/07_demo_reset_and_deploy.sh`: limpa tudo, testa, builda e sobe homologacao/producao.
- `scripts/08_update_from_github.sh`: atualiza a VM com `git pull`.

Para uma apresentacao completa, rode:

```bash
scripts/clean_docker_images.sh
scripts/02_run_checks_docker.sh
docker build -t receitas-app:latest .
scripts/03_deploy_homolog.sh
scripts/04_deploy_prod.sh
scripts/05_status.sh
scripts/06_test_urls.sh
```

Para desenvolver no seu PC com container:

```bash
scripts/00_dev_up.sh
```

Depois acesse:

```text
http://localhost:5002
```

Edite o codigo no VS Code normalmente. O container de desenvolvimento monta a pasta do projeto dentro de `/app`.

Ou rode tudo de uma vez:

```bash
scripts/07_demo_reset_and_deploy.sh
```
