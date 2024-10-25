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
                            docker-compose up -d --build
                        '''
                    } else {
                        echo "Ollama is already running on port 11435. Skipping start."
                        sh '''
                            docker-compose up -d --no-recreate python-app
                        '''
                    }
                }
            }
        }

        stage('Install Ollama in Ollama Container') {
            steps {
                script {
                    // Install Ollama inside the Ollama container if it is not installed
                    sh '''
                        # Check if the Ollama command is available
                        if ! docker exec ollama-container bash -c "command -v ollama"; then
                            echo 'Ollama not found. Installing...';
                            # Assuming ollama is installed via pip
                            docker exec ollama-container bash -c "pip install ollama"
                        else
                            echo 'Ollama is already installed.';
                        fi
                    '''
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
                        
                        # Start Streamlit app in background to allow ollama to run concurrently
                        docker exec python-app bash -c "streamlit run app.py --server.headless true > /tmp/streamlit.log 2>&1 &"
                        
                        # Loop to keep the job alive while both apps run
                        while true; do
                            echo "Streamlit app is running in Docker container..."
                            sleep 60;
                        done
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