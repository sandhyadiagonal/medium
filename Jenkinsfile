pipeline {
    agent { label 'windows' }

    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/sandhyadiagonal/medium.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image using the Dockerfile
                    docker.build("chatbot-app")
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    sh 'docker-compose up -d'
                    // Run your test script or any unit tests
                    //sh 'docker exec chatbot-app pytest tests/'
                    sh 'docker-compose down'
                }
            }
        }
    }

    post {
        always {
            sh 'docker-compose down'
        }
    }
}
