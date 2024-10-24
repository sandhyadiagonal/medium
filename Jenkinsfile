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
                    // Check if the Ollama container is running on port 11435
                    def isOllamaRunning = sh(script: '''
                        if lsof -iTCP:11435 -sTCP:LISTEN; then
                            echo "true"
                        else
                            echo "false"
                        fi
                    ''', returnStdout: true).trim()

                    if (isOllamaRunning == "false") {
                        echo "Ollama is not running. Starting Ollama and other containers with Docker Compose."
                        sh '''
                            docker-compose down
                            docker build -t langchain .
                            docker build -t ollama/ollama .
                            docker-compose up -d --build
                        '''
                    } else {
                        echo "Ollama is already running on port 11435. Skipping start."
                        // Start other services without recreating the Ollama container
                        sh '''
                            docker-compose up -d --no-recreate python-app
                        '''
                    }
                }
            }
        }

        stage('Pull Ollama Model in Ollama Container') {
            steps {
                script {
                    // Check if the model phi:latest exists, and pull it if it doesn't
                    def modelExists = sh(script: '''
                        docker exec ollama-container bash -c "ollama list | grep -q 'phi:latest'"
                    ''', returnStatus: true)

                    if (modelExists != 0) {
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

        stage('Run Streamlit App in Docker Container') {
            steps {
                script {
                    sh '''
                        docker exec python-app bash -c "pip install --upgrade pip --root-user-action=ignore && pip install -r requirements.txt"
                        docker exec python-app bash -c "streamlit run app.py --server.headless true --server.port 8502 > /tmp/streamlit.log 2>&1"
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
                        docker cp python-app:/tmp/streamlit.log ./streamlit.log
                    '''
                    // Display the contents of the log file
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
