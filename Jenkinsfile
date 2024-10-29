pipeline {
    agent { label 'linux' }

    stages {

        stage('Docker Login') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker_credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh '''
                            echo $PASSWORD | docker login -u $USERNAME --password-stdin
                        '''
                    }
                }
            }
        }

        stage('Build and Push Docker Images') {
            steps {
                script {
                    sh '''
                        docker build -t sandhyadiagonal/medium:python-app -f Dockerfile.python-app .
                    '''
                    sh '''
                        docker push sandhyadiagonal/medium:python-app
                    '''
                    sh '''
                        docker build -t sandhyadiagonal/medium:ollama-container -f Dockerfile.ollama-container .
                    '''
                    sh '''
                        docker push sandhyadiagonal/medium:ollama-container
                    '''
                }
            }
        }

        stage('Run Containers with Docker Compose') {
            steps {
                script {
                    sh '''
                        docker-compose down
                        docker-compose up -d --build
                    '''
                }
            }
        }

        stage('Pull Ollama Model in Ollama Container') {
            steps {
                script {
                    def modelExists = sh(script: '''
                        if ollama list | grep -q "phi:latest"; then
                            echo "true"
                        else
                            echo "false"
                        fi
                    ''', returnStdout: true).trim()

                    if (modelExists == "false") {
                        sh '''
                            docker exec ollama-container bash -c "ollama pull phi:latest"
                        '''
                    } else {
                        echo "Model phi:latest already exists. Skipping pull."
                    }
                }
            }
        }

        stage('Run Streamlit App in Docker Container') {
            steps {
                script {
                    while (true) {
                        echo "Streamlit app is running in Docker container..."
                        sleep 60
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                sh '''
                    echo "The session will end when the job finishes."
                '''
            }
        }
    }
}
