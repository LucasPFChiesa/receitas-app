pipeline {
    agent any

    environment {
        APP_VERSION = "${env.BUILD_NUMBER}"
        IMAGE_NAME = "receitas-app"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Preparar ambiente') {
            steps {
                sh '''
                    python3 -m venv .venv
                    . .venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements-dev.txt
                '''
            }
        }

        stage('Lint') {
            steps {
                sh '''
                    . .venv/bin/activate
                    pyflakes app.py init_db.py tests
                '''
            }
        }

        stage('Testes') {
            steps {
                sh '''
                    . .venv/bin/activate
                    pytest -q
                '''
            }
        }

        stage('Build imagem') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${APP_VERSION} -t ${IMAGE_NAME}:latest .'
            }
        }

        stage('Deploy homologacao') {
            steps {
                sh 'APP_VERSION=${APP_VERSION} sh scripts/docker-compose.sh up -d homolog'
            }
        }

        stage('Validar homologacao') {
            steps {
                sh '''
                    sleep 5
                    curl --fail http://localhost:5001/login
                '''
            }
        }

        stage('Deploy producao') {
            when {
                branch 'main'
            }
            steps {
                sh 'APP_VERSION=${APP_VERSION} sh scripts/docker-compose.sh --profile prod up -d prod'
            }
        }
    }

    post {
        always {
            sh 'sh scripts/docker-compose.sh ps || true'
        }
    }
}
