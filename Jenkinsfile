pipeline {
    agent any

    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Setup') {
            steps {
                echo 'Verifying Bandit...'
                sh 'bandit --version'
            }
        }

        stage('SAST - Bandit: Bad Code') {
            steps {
                echo 'Scanning vulnerable code...'
                sh '''
                    cd /vulpy
                    bandit -r bad -f html -o bandit-bad.html || true
                '''
            }
        }

        stage('SAST - Bandit: Good Code') {
            steps {
                echo 'Scanning corrected code...'
                sh '''
                    cd /vulpy
                    bandit -r good -f html -o bandit-good.html || true
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh '''
                    cd /vulpy
                    docker build -t vulpy:latest -f Dockerfile . || true
                '''
            }
        }

        stage('SCA - Trivy: Image Scan') {
            steps {
                echo 'Scanning Docker image for vulnerabilities...'
                sh '''
                    cd /vulpy
                    trivy image --format json --output trivy-image.json vulpy:latest || true
                    trivy image --format table vulpy:latest || true
                '''
            }
        }

        stage('SCA - Trivy: Filesystem Scan') {
            steps {
                echo 'Scanning filesystem for vulnerabilities...'
                sh '''
                    cd /vulpy
                    trivy fs --format json --output trivy-fs.json . || true
                    trivy fs --severity HIGH,CRITICAL --format table . || true
                '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'
            archiveArtifacts artifacts: '**/*.html,**/*.json', 
                             allowEmptyArchive: true
            sh '''
                cp /vulpy/bandit-*.html . 2>/dev/null || true
                cp /vulpy/trivy-*.json . 2>/dev/null || true
            '''
        }

        success {
            echo 'SUCCESS!'
        }

        failure {
            echo 'FAILED - Check logs'
        }
    }
}

