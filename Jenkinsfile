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
                    '''
                }
            }        
        }
    }

    post {
        always {
            script {
                bat 'deactivate'
            }        
        }    
    }
}
