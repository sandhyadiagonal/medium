pipeline {
    agent { label 'linux' }

    stages {
        stage('Create Virtual Environment') {
            steps {
                script {
                    sh '''
                        python3 -m venv env
                        source ./env/bin/activate
                        pip install --upgrade pip
                        pip install streamlit
                        pip install -r requirements.txt
                    '''
                }
            }
        }

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

        stage('Pull Docker Images from Docker Hub') {
            steps {
                script {
                    sh '''
                        docker pull sandhyadiagonal/medium:python-app
                        docker pull sandhyadiagonal/medium:ollama-container
                    '''
                }
            }
        }

        stage('Run Python App Container') {
            steps {
                script {
                    sh '''
                        docker run -d --name python-app -p 8501:8501 sandhyadiagonal/medium:python-app
                    '''
                }
            }
        }

        stage('Run Ollama Container') {
            steps {
                script {
                    sh '''
                        docker run -d --name ollama-container -p 11434:11434 sandhyadiagonal/medium:ollama-container
                    '''
                }
            }
        }

        stage('Pull Ollama Model in Ollama Container') {
            steps {
                script {
                    def modelExists = sh(script: '''
                        if docker exec ollama-container bash -c "ollama list | grep -q 'phi:latest'"; then
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

        stage('Setup Streamlit Config') {
            steps {
                script {
                    // Create the Streamlit config directory and file with the required setting
                    sh '''
                        mkdir -p ~/.streamlit
                        echo "[browser]" > ~/.streamlit/config.toml
                        echo "gatherUsageStats = false" >> ~/.streamlit/config.toml
                    '''
                }
            }
        }

        stage('Run Streamlit App in Python App Container') {
            steps {
                script {
                    sh '''
                        docker exec python-app bash -c "pip install --upgrade pip --root-user-action=ignore && pip install -r requirements.txt"
                        docker exec python-app bash -c "streamlit run app.py --server.headless true --server.port 8501 > /tmp/streamlit.log 2>&1"
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
                sh '''
                    echo "The session will end when the job finishes."
                '''
            }
        }
    }
}
