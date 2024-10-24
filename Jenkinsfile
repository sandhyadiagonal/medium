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
                        if sudo docker exec ollama-container ollama list | grep -q "phi:latest"; then
                            echo "true"
                        else
                            echo "false"
                        fi
                    ''', returnStdout: true).trim()

                    if (modelExists == "false") {
                        sh '''
                            sudo docker exec ollama-container bash -c "ollama pull phi:latest"
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
                    sh '''
                        mkdir -p ~/.streamlit
                        echo "[browser]" > ~/.streamlit/config.toml
                        echo "gatherUsageStats = false" >> ~/.streamlit/config.toml
                    '''
                }
            }
        }

        stage('Run Streamlit App in Docker Container') {
            steps {
                script {
                    sh '''
                        sudo docker exec python-app bash -c "pip install --upgrade pip --root-user-action=ignore && pip install -r requirements.txt"
                        sudo docker exec python-app bash -c "streamlit run app.py --server.headless true --server.port 8502 > /tmp/streamlit.log 2>&1"
                    '''
                    // Loop to keep the job alive while the Streamlit app runs
                    while (true) {
                        echo "Streamlit app is running in Docker container..."
                        sleep 60
                    }
                }
            }
        }

        stage('Copy Streamlit Log to Host') {
            steps {
                script {
                    // Copy the log file from the container to the host
                    sh '''
                        sudo docker cp python-app:/tmp/streamlit.log ./streamlit.log
                    '''
                    sh '''
                        echo "Streamlit Log Contents:"
                        cat ./streamlit.log
                    '''
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
