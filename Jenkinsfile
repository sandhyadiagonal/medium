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
                        docker pull sandhyadiagonal/medium:ollama
                        docker pull sandhyadiagonal/medium:streamlitimage
                    '''
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    bat '''
                        docker run -d --name streamlit_container -p 8501:8501 -v %CD%:/app -w /app sandhyadiagonal/medium:streamlitimage
                    '''
                }
            }
        }

        stage('Run Streamlit App in Docker Container') {
            steps {
                script {
                    bat '''
                        docker exec streamlit_container bash -c "pip install --upgrade pip && pip install -r requirements.txt && streamlit run app.py --server.headless true > streamlit.log 2>&1"
                    '''
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
                bat '''
                    echo The session will end when the job finishes.
                '''
            }
        }
    }
}
