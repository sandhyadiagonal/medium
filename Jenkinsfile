pipeline {
    agent { label 'windows' }

    stages {
        stage('Create Virtual Environment') {
            steps {
                script {
                    bat '''
                        python -m venv env
                        call .\\env\\Scripts\\activate
                        pip install --upgrade pip
                        pip install streamlit
                        pip install -r requirements.txt
                    '''
                }
            }
        }

        stage('Run Containers with Docker Compose (Linux)') {
            agent { label 'linux' }  // Specify Linux node for Docker operations
            steps {
                script {
                    sh '''
                        docker-compose down
                        docker-compose up -d --build
                    '''
                }
            }
        }

        stage('Pull Ollama Model in Ollama Container (Linux)') {
            agent { label 'linux' }  // Specify Linux node
            steps {
                script {
                    sh '''
                        docker exec ollama-container bash -c "ollama pull phi:latest"
                    '''
                }
            }
        }

        stage('Run Streamlit App in Docker Container (Linux)') {
            agent { label 'linux' }  // Specify Linux node
            steps {
                script {
                    // Start the Streamlit app and redirect logs
                    sh '''
                        docker exec python-app bash -c "pip install --upgrade pip --root-user-action=ignore && pip install -r requirements.txt"
                        docker exec python-app bash -c "streamlit run app.py --server.headless true --server.port 8501"
                    '''
                }
            }
        }
    }

    post {
        always {
            agent { label 'linux' }  // Ensure cleanup also happens on Linux
            script {
                sh '''
                    echo "The session will end when the job finishes."
                '''
            }
        }
    }
}
