# Deploy na VM

Esta VM concentra os ambientes do desenho:

- Integração: Jenkins rodando na própria VM.
- Homologação: container `receitas_app_homolog`.
- Produção: container `receitas_app_prod`.

Dados da VM mostrada:

- IP: `177.44.248.83`
- Usuário SSH: `univates`
- Pasta do projeto: `/home/univates/projeto/receitas-app`

## 1. Acessar a VM

```bash
ssh univates@177.44.248.83
cd ~/projeto/receitas-app
```

## 2. Instalar dependências da VM

Execute na VM:

```bash
sudo apt update
sudo apt install -y git python3 python3-venv python3-pip docker.io docker-compose curl
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

## 3. Enviar as alteracoes novas para a VM

O projeto local precisa ir para o GitHub primeiro:

```bash
git add .
git commit -m "Configura pipeline Jenkins e Docker"
git push
```

Na VM, atualize o projeto:

```bash
cd ~/projeto/receitas-app
git pull
```

Depois do `git pull`, a VM deve ter estes arquivos novos:

- `Dockerfile`
- `docker-compose.yml`
- `Jenkinsfile`
- `.dockerignore`
- `docker-entrypoint.sh`
- `requirements-dev.txt`
- `scripts/docker-compose.sh`

## 4. Testar homologacao manualmente

Na VM:

```bash
cd ~/projeto/receitas-app
docker-compose up -d homolog
docker-compose ps
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
cd ~/projeto/receitas-app
docker-compose --profile prod up -d prod
docker-compose ps
```

Produção:

```text
http://177.44.248.83:5000
```

## 6. Instalar Jenkins

Se o Jenkins ainda não estiver instalado, execute na VM:

```bash
sudo apt install -y fontconfig openjdk-17-jre
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins
sudo systemctl enable --now jenkins
```

Acesse:

```text
http://177.44.248.83:8080
```

Senha inicial:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Permitir que o Jenkins use Docker:

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

## 7. Criar job Pipeline no Jenkins

No Jenkins:

1. Clique em `New Item`.
2. Escolha `Pipeline`.
3. Em `Pipeline`, selecione `Pipeline script from SCM`.
4. SCM: `Git`.
5. Repository URL: URL do repositório GitHub.
6. Branch: `*/main`.
7. Script Path: `Jenkinsfile`.
8. Salve e execute `Build Now`.

## 8. Resultado esperado

O Jenkins deve executar:

1. Buscar código no GitHub.
2. Criar ambiente Python.
3. Instalar `requirements-dev.txt`.
4. Rodar `pyflakes`.
5. Rodar `radon` como mess detector.
6. Rodar `pytest`.
7. Criar imagem Docker.
8. Subir homologação em `5001`.
9. Se estiver na branch `main`, subir produção em `5000`.

## 9. Portas usadas

- Jenkins: `8080`
- Homologação: `5001`
- Produção: `5000`

Se a VM tiver firewall ou regra de nuvem, libere essas portas.

## 10. Scripts prontos para apresentacao

Dentro da VM, na pasta do projeto:

```bash
cd ~/projeto/receitas-app
```

Limpar Docker como o professor pediu:

```bash
scripts/clean_docker_images.sh
```

Rodar a demonstracao completa:

```bash
scripts/07_demo_reset_and_deploy.sh
```

Ver status:

```bash
scripts/05_status.sh
```

Testar URLs:

```bash
scripts/06_test_urls.sh
```
