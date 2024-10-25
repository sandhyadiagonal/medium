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

        stage('Setup Streamlit Config') {
            steps {
                script {
                    // Create the Streamlit config directory and Streamlit won’t collect and send usage data. This is particularly useful in a corporate environment or when privacy and data security are critical
                    sh '''
                        mkdir -p ~/.streamlit
                        echo "[browser]" > ~/.streamlit/config.toml
                        echo "gatherUsageStats = false" >> ~/.streamlit/config.toml
                    '''
                }
            }
        }

        stage('Approval') {
            steps {
                script {
                    // Get the latest commit details
                    def commitMessage = sh(script: 'git log -1 --pretty=format:"%s"', returnStdout: true).trim()
                    def commitAuthor = sh(script: 'git log -1 --pretty=format:"%an"', returnStdout: true).trim()
                    def commitHash = sh(script: 'git log -1 --pretty=format:"%h"', returnStdout: true).trim()

                    // Email notification for approval with commit details
                    mail to: 'sandhyayadav0911@gmail.com',
                        cc: 'sandhya.yadav@diagonal.ai',            
                        subject: "Approval Needed for Job ${env.JOB_NAME}",
                        body: """\
        Hi,

        Please approve the build by reviewing the following details:

        - Job Name: ${env.JOB_NAME}
        - Build URL: ${env.BUILD_URL}
        - Branch: ${env.GIT_BRANCH}
        - Commit Hash: ${commitHash}
        - Author: ${commitAuthor}
        - Commit Message: ${commitMessage}

        Click the following link to approve the build: ${env.BUILD_URL}input/

        Regards,
        Jenkins
        """
                    echo 'Waiting for approval...'
                    input message: 'Do you approve this build?', ok: 'Approve'
                }
            }
        }


        stage('Run Streamlit App in Docker Container') {
            steps {
                script {
                    sh '''
                        docker exec python-app bash -c "pip install --upgrade pip --root-user-action=ignore && pip install -r requirements.txt"
                        docker exec python-app bash -c "streamlit run app.py --server.headless true --server.port 8501 > /tmp/streamlit.log 2>&1"
                    '''
                    // Loop to keep the job alive while the Streamlit app runs
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
