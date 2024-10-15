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
                    bat '''
                        .\\env\\Scripts\\activate
                        streamlit run app.py
                        timeout /t 300
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                bat '''
                    echo Virtual environment does not need explicit deactivation in Windows.
                    echo The session will end when the job finishes.
                '''
            }
        }
    }
}