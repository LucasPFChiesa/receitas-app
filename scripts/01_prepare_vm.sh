#!/usr/bin/env bash
set -e

echo "Instalando dependencias principais da VM..."
sudo apt update
sudo apt install -y git python3 python3-venv python3-pip docker.io docker-compose curl fontconfig openjdk-17-jre

echo "Ativando Docker..."
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

echo "Preparando Jenkins..."
if ! command -v jenkins >/dev/null 2>&1; then
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
        | sudo tee /usr/share/keyrings/jenkins-keyring.asc >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
        | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null
    sudo apt update
    sudo apt install -y jenkins
fi

sudo systemctl enable --now jenkins
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

echo "VM preparada."
echo "Saia e entre de novo no SSH para o grupo docker valer para o usuario $USER."
echo "Jenkins: http://177.44.248.83:8080"
echo "Senha inicial:"
echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
