pipeline {
    agent { label 'windows' }

    stages {
        // this is test of repo for changes in git then build auto
        // stage('Clone Repository') {
        //     steps {
        //         script {
        //             git branch: 'main', url: 'https://github.com/sandhyadiagonal/medium.git'
        //         }
        //     }
        //}

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
