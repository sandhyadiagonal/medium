pipeline {
    agent { label 'windows' }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    // Correct the git step syntax
                    git branch: 'main', url: 'https://github.com/sandhyadiagonal/medium.git'
                }        }        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image using the Dockerfile
                    docker.build("chatbot-app")
                }         }        }

        stage('Run Tests') {
            steps {
                script {
                    // Start the Docker containers using docker-compose
                    bat 'docker-compose up -d'
                    // Uncomment the next line to run your test script or any unit tests
                    // bat 'docker exec chatbot-app pytest tests/'
                    // Shutdown the Docker containers
                    bat 'docker-compose down'
                }      }        }    }

    post {
        always {
            script {
                bat 'docker-compose down'
            }        }    }   }
