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
                        .\\env\\Scripts\\activate
                        pip install --upgrade pip
                        pip install -r requirements.txt
                    '''
                }
            }
        }

        stage('Run Streamlit App') {
            steps {
                script {
                    // Combine the activation and running command in one bat step
                    bat '''
                        call .\\env\\Scripts\\activate
                        start /B cmd /C "streamlit run app.py --server.port=8501 > streamlit.log 2>&1"
                        timeout /t 180
                    '''
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
