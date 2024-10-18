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

        stage('Pull Docker Images from Docker Hub') {
            steps {
                script {
                    bat '''
                        docker pull sandhyadiagonal/medium:ollama-container
                        docker pull sandhyadiagonal/medium:python-app
                    '''
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    bat '''
                        docker run -d --name python-app -p 8501:8501 -v %CD%:/app -w /app sandhyadiagonal/medium:python-app
                    '''
                }
            }
        }

        stage('Run Streamlit App in Docker Container') {
            steps {
                script {
                    bat '''
                        docker exec python-app bash -c "pip install --upgrade pip --root-user-action=ignore && pip install -r requirements.txt"
                        docker exec python-app bash -c "streamlit run app.py --server.headless true > /tmp/streamlit.log 2>&1"
                    '''
                    while (true) {
                        echo "Streamlit app is running in Docker container on port 8501..."
                        sleep 60
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                bat '''
                    echo The session will end when the job finishes.
                '''
            }
        }
    }
}
