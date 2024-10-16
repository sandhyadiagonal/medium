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

        stage('Run Streamlit App') {
            steps {
                script {
                    def output = bat(returnStdout: true, script: '''
                    .\\env\\Scripts\\activate && streamlit run app.py --server.port 8501 --server.address 0.0.0.0 > streamlit.log 2>&1
                    ''')
                    echo "Output:\n${output}"
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
