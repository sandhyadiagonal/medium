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

        stage('Pull Docker Images') {
            steps {
                script {
                    bat '''
                        docker pull sandhyadiagonal/medium:python-app
                        docker pull sandhyadiagonal/medium:ollama-container
                    '''
                }
            }
        }

        stage('Run Docker Containers') {
            steps {
                script {
                    bat '''
                        docker ps -a -q --filter "name=ollama-container" | findstr . && docker stop ollama-container && docker rm ollama-container
                        docker run -d --name ollama-container sandhyadiagonal/medium:ollama-container

                        docker ps -a -q --filter "name=python-app" | findstr . && docker stop python-app && docker rm python-app
                        docker run -d --name python-app -p 8501:8501 sandhyadiagonal/medium:python-app
                    '''
                }
            }
        }

        stage('Pull Ollama Model in Ollama Container') {
            steps {
                script {
                    def modelExists = bat(script: '''
                        if docker exec ollama-container ollama list | findstr "phi:latest" >nul; then
                            echo true
                        else
                            echo false
                        fi
                    ''', returnStdout: true).trim()

                    if (modelExists == "false") {
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
                    bat '''
                        mkdir %USERPROFILE%\\.streamlit
                        echo [browser] > %USERPROFILE%\\.streamlit\\config.toml
                        echo gatherUsageStats = false >> %USERPROFILE%\\.streamlit\\config.toml
                    '''
                }
            }
        }

        stage('Run Streamlit App in Docker Container') {
            steps {
                script {
                    bat '''
                        docker exec python-app pip install --upgrade pip
                        docker exec python-app pip install -r requirements.txt
                        docker exec python-app streamlit run app.py --server.headless true --server.port 8501 > C:\\tmp\\streamlit.log 2>&1
                    '''
                    while (true) {
                        echo "Streamlit app is running in Docker container..."
                        sleep 60
                    }
                }
            }
        }

        stage('Approval') {
            steps {
                script {
                    def commitMessage = bat(script: 'git log -1 --pretty=format:"%s"', returnStdout: true).trim()
                    def commitAuthor = bat(script: 'git log -1 --pretty=format:"%an"', returnStdout: true).trim()
                    def commitHash = bat(script: 'git log -1 --pretty=format:"%h"', returnStdout: true).trim()

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

        stage('Copy Streamlit Log to Host') {
            steps {
                script {
                    bat '''
                        docker cp python-app:/tmp/streamlit.log C:\\tmp\\streamlit.log
                    '''
                    bat '''
                        type C:\\tmp\\streamlit.log
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
