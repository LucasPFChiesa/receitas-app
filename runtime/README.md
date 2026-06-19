# Runtime da VM

Esta pasta contem o necessario para operar homologacao/producao sem clone
permanente do codigo-fonte na VM.

Uso em VM nova:

```bash
mkdir -p ~/receitas-runtime
curl -fsSL https://raw.githubusercontent.com/LucasPFChiesa/receitas-app/main/runtime/start.sh -o ~/receitas-runtime/start.sh
chmod +x ~/receitas-runtime/start.sh
bash ~/receitas-runtime/start.sh
```

Depois disso a VM usa:

- Docker;
- self-hosted runner em `~/actions-runner`;
- runtime operacional em `~/receitas-runtime`;
- imagens Docker do GHCR;
- volumes Docker dos bancos.
