pipeline {
    agent { label 'linux' }

    stages {

        stage('Create Virtual Environment') {
            steps {
                script {
                    sh '''
                        python3 -m venv env
                        source ./env/bin/activate
                        pip install --upgrade pip setuptools wheel
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
                            source ./env/bin/activate
                            echo $PASSWORD | docker login -u $USERNAME --password-stdin
                        '''
                    }
                }
            }
        }

        stage('Build and Push Docker Images') {
            steps {
                script {
                    sh '''
                        source ./env/bin/activate
                        docker build -t sandhyadiagonal/medium:python-app -f Dockerfile .
                        docker push sandhyadiagonal/medium:python-app
                        docker pull ollama/ollama:latest
                        docker-compose down
                        docker-compose up -d
                    '''
                }
            }
        }

        stage('Approval') {
            steps {
                script {
                    def repoURL = "https://github.com/sandhyadiagonal/medium"
                    def blueOceanURL = "${env.JENKINS_URL}/blue/organizations/jenkins/${env.JOB_NAME}/detail/${env.JOB_NAME}/${env.BUILD_NUMBER}/pipeline"
                    def dockerhubURL = "https://hub.docker.com/r/sandhyadiagonal/medium/tags"

                    echo "Review GitHub Repository: ${repoURL}"
                    echo "Review DockerHub: ${dockerhubURL}"
                    echo "View the logs at: ${env.BUILD_URL}/console"

                    mail from: 'Pipeline approval <noreply@yourdomain.com>',
                         to: 'sandhyayadav0911@gmail.com',
                         cc: 'sandhya.yadav@diagonal.ai',
                         subject: "Approval Needed for Job ${env.JOB_NAME}",
                         body: """\
Hi,

Please approve the build by reviewing the following details:

- Job Name: ${env.JOB_NAME}
- Started By: ${env.BUILD_USER_ID}

Kindly refer to this link to view the details: ${blueOceanURL}

Regards,
Jenkins
"""
                    input message: """\
Have you thoroughly reviewed the necessary code changes before approving this build? Do you approve this build? """, ok: 'Approve'
                }
            }
        }
        
        stage('Pull Ollama Model in Ollama Container') {
            steps {
                script {
                    def modelExists = sh(script: '''
                        source ./env/bin/activate
                        if ollama list | grep -q "phi:latest"; then
                            echo "true"
                        else
                            echo "false"
                        fi
                    ''', returnStdout: true).trim()

                    if (modelExists == "false") {
                        sh '''
                            source ./env/bin/activate
                            docker exec ollama-container bash -c "ollama pull phi:latest"
                        '''
                    } else {
                        echo "Model phi:latest already exists. Skipping pull."
                    }
                }
            }
        }

        stage('Run Streamlit App in Docker Container') {
            steps {
                script {
                    while (true) {
                        echo "Streamlit app is running in Docker container..."
                        sleep 60
                    }
                }
            }
        }
    }

    post {
        failure {
            mail from: 'Pipeline approval <noreply@yourdomain.com>',
                 to: 'sandhyayadav0911@gmail.com',
                 cc: 'sandhya.yadav@diagonal.ai',
                 subject: "Failed: Build ${env.JOB_NAME}",
                 body: "Build failed for ${env.JOB_NAME}, Build number: ${env.BUILD_NUMBER}.\n\n View the logs at: \n ${env.BUILD_URL}"
        }

        success {
            mail from: 'Pipeline approval <noreply@yourdomain.com>',
                 to: 'sandhyayadav0911@gmail.com',
                 cc: 'sandhya.yadav@diagonal.ai',
                 subject: "Successful: Build ${env.JOB_NAME}",
                 body: "Build Successful for ${env.JOB_NAME}, Build number: ${env.BUILD_NUMBER}.\n\n View the logs at: \n ${env.BUILD_URL}"
        }
    }
}
