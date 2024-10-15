pipeline {
    agent { label 'windows' }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    git branch: 'main', url: 'https://github.com/sandhyadiagonal/medium.git'
                }         }        }

        stage('Create Virtual Environment') {
            steps {
                script {
                    bat '''
                        python -m venv env
                        .\\env\\Scripts\\activate
                        pip install --upgrade pip
                        pip install -r requirements.txt
                    '''
                }            }        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("chatbot-app")
                }            }        }

        stage('Run Tests') {
            steps {
                script {
                    bat 'docker-compose up -d'
                    // Uncomment the next line to run your test script or any unit tests
                    // bat 'docker exec chatbot-app pytest tests/'
                    // Shutdown the Docker containers
                    bat 'docker-compose down'
                }            }        }    }

    post {
        always {
            script {
                bat 'docker-compose down'
            }        }    }
}
