pipeline {
    agent { label 'windows' }

    stages {
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

        // stage('Approval Request') {
        //     steps {
        //         script {
        //             mail(
        //                 to: 'sandhyayadav0911@gmail.com',
        //                 subject: "Job '${env.JOB_BASE_NAME}' (${env.BUILD_NUMBER}) is waiting for input",
        //                 body: "Please go to console output of ${env.BUILD_URL} to approve or Reject."
        //             )
                    
        //             def userInput = input(id: 'userInput', message: 'Job A Failed do you want to build Job B?', ok: 'Yes')
        //         }
        //     }
        // }

        stage('Run Streamlit App') {
            steps {
                script {
                    bat '''
                        start cmd /c "call .\\env\\Scripts\\activate && streamlit run app.py --server.headless true > streamlit.log 2>&1"
                    '''
                    while (true) {
                        echo "Streamlit app is running..."
                        sleep 60
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                bat '''
                    echo The session will end when the job finishes.
                '''
            }
        }
    }
}
