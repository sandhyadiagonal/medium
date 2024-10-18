pipeline {
    agent { label 'windows' }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    git branch: 'main', url: 'https://github.com/sandhyadiagonal/medium.git'
                }
            }
        }

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

        stage('Approval') {
            steps {
                script {
                    def commitMessage = sh(script: 'git log -1 --pretty=%B', returnStdout: true).trim()
                    def commitAuthor = sh(script: 'git log -1 --pretty=%an', returnStdout: true).trim()
                    def commitHash = sh(script: 'git log -1 --pretty=%h', returnStdout: true).trim()
                    
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

        stage('Run Streamlit App') {
            steps {
                script {
                    bat '''
                        start cmd /c "call .\\env\\Scripts\\activate && streamlit run app.py --server.headless true > streamlit.log 2>&1"
                    '''
                    while (true) {
                        echo "Streamlit app is running on port 8501..."
                        sleep 60
                    }
                }
            }
        }
    }

    post {
        failure {
            mail to: 'sandhyayadav0911@gmail.com',
                 cc: 'sandhya.yadav@diagonal.ai',
                 subject: "Failed: Build ${env.JOB_NAME}",
                 body: "Build failed ${env.JOB_NAME} and Build number: ${env.BUILD_NUMBER}.\n\n View the logs at: \n ${env.BUILD_URL}"
        }
    
        success {
            mail to: 'sandhyayadav0911@gmail.com',
                 cc: 'sandhya.yadav@diagonal.ai',
                 subject: "Successful: Build ${env.JOB_NAME}",
                 body: "Build Successful ${env.JOB_NAME} and Build number: ${env.BUILD_NUMBER}.\n\n View the logs at: \n ${env.BUILD_URL}"
        }
    }
}
