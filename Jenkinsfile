pipeline {
    agent { label 'windows' }

    stages {
        stage('Create Virtual Environment') {
            steps {
                script {
                    bat '''
                        python -m venv env
                        call .\\env\\Scripts\\activate
                        python -m pip install --upgrade pip
                        pip install streamlit
                        pip install -r requirements.txt
                    '''
                }
            }
        }

        stage('Test Docker Login') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker_credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        bat '''
                            docker logout
                            docker login -u %USERNAME% -p %PASSWORD%
                        '''
                    }
                }
            }
        }

        stage('Run Docker Containers with Docker Compose') {
            steps {
                script {
                    bat '''
                        docker-compose down
                        docker-compose up -d
                    '''
                }
            }
        }

        stage('Pull Ollama Model in Ollama Container') {
            steps {
                script {
                    def modelCheckStatus = bat(script: '''
                        docker exec ollama-container ollama list | findstr "phi:latest"
                        exit /b %ERRORLEVEL%
                    ''', returnStatus: true)

                    if (modelCheckStatus != 0) {
                        echo "Model phi:latest not found. Pulling model..."
                        bat '''
                            docker exec ollama-container ollama pull phi:latest
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
                    def streamlitConfigDir = "%USERPROFILE%\\.streamlit"

                    bat """
                        mkdir ${streamlitConfigDir} || echo "Directory already exists"
                        echo [browser] > ${streamlitConfigDir}\\config.toml
                        echo gatherUsageStats = false >> ${streamlitConfigDir}\\config.toml
                    """
                }
            }
        }

        stage('Run Streamlit App in Docker Container') {
            steps {
                script {
                    bat '''
                        docker exec python-app pip install --upgrade pip
                        docker exec python-app pip install -r requirements.txt
                        docker exec python-app streamlit run app.py --server.headless true > streamlit.log 2>&1
                    '''
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
                    bat '''
                        docker cp python-app:/tmp/streamlit.log C:\\Users\\SandhyaYadav\\streamlit.log
                    '''
                    bat '''
                        type C:\\Users\\SandhyaYadav\\streamlit.log
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                bat '''
                    echo "The session will end when the job finishes."
                '''
            }
        }
    }
}
