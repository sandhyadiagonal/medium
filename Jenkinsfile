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
                    mail to: 'sandhyayadav0911@gmail.com',
                         cc: 'sandhya.yadav@diagonal.ai',            
                         subject: "Approval Needed for Job ${env.JOB_NAME}",
                         body: "Please approve the build by clicking on the following link: ${env.BUILD_URL}input/"
                    
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
                        echo "Streamlit app is running in Docker container on port 8501..."
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
