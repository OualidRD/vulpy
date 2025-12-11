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

        stage('Setup Tools') {
            steps {
                echo 'Installing/verifying security tools...'
                script {
                    sh '''
                        # Ensure Trivy is available
                        if ! command -v trivy &> /dev/null; then
                            echo "Installing Trivy..."
                            cd /tmp
                            rm -f trivy.tar.gz 2>/dev/null || true
                            curl -fL https://github.com/aquasecurity/trivy/releases/download/v0.48.0/trivy_0.48.0_Linux-64bit.tar.gz -o trivy.tar.gz
                            tar xzf trivy.tar.gz trivy --no-same-owner 2>/dev/null || tar xzf trivy.tar.gz trivy
                            mv trivy /usr/local/bin/
                            rm -f trivy.tar.gz
                            chmod +x /usr/local/bin/trivy
                        fi
                        echo "Verifying tools:"
                        bandit --version
                        trivy --version
                    '''
                }
            }
        }

        stage('SAST - Bandit') {
            steps {
                echo 'Running Bandit SAST analysis...'
                script {
                    // Scan bad directory
                    sh '''
                        echo "Scanning /vulpy/bad directory..."
                        bandit -r /vulpy/bad -f html -o /vulpy/bandit-bad.html || true
                    '''
                    
                    // Scan good directory
                    sh '''
                        echo "Scanning /vulpy/good directory..."
                        bandit -r /vulpy/good -f html -o /vulpy/bandit-good.html || true
                    '''
                }
            }
        }

        stage('SCA - Trivy: Requirements') {
            steps {
                echo 'Running Trivy SCA on requirements.txt...'
                script {
                    sh '''
                        trivy fs --scanners vuln --format json --output /vulpy/trivy-requirements.json /vulpy/requirements.txt || true
                    '''
                }
            }
        }

        stage('SCA - Trivy: Dependencies') {
            steps {
                echo 'Running Trivy SCA on dependencies...'
                script {
                    sh '''
                        trivy fs --scanners vuln,misconfig --format json --output /vulpy/trivy-dependencies.json /vulpy/bad /vulpy/good || true
                    '''
                }
            }
        }

        stage('SCA - Trivy: Transitive Dependencies') {
            steps {
                echo 'Running Trivy SCA on transitive dependencies...'
                script {
                    sh '''
                        trivy fs --scanners vuln --severity CRITICAL,HIGH --format json --output /vulpy/trivy-transitive.json /vulpy || true
                    '''
                }
            }
        }

        stage('SCA - Trivy: Secrets & Config') {
            steps {
                echo 'Running Trivy SCA on secrets and configuration files...'
                script {
                    sh '''
                        trivy fs --scanners secret,config --format json --output /vulpy/trivy-secrets-config.json /vulpy || true
                    '''
                }
            }
        }

        stage('SCA - Trivy: Supply Chain') {
            steps {
                echo 'Running Trivy SCA on supply chain...'
                script {
                    sh '''
                        trivy image --scanners vuln --format json --output /vulpy/trivy-supply-chain.json python:3.11-slim || true
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Vulpy Docker image...'
                script {
                    sh '''
                        cd /vulpy
                        docker build -t vulpy:latest -f Dockerfile . || true
                    '''
                }
            }
        }

        stage('Scan Docker Image') {
            steps {
                echo 'Scanning Vulpy Docker image with Trivy...'
                script {
                    sh '''
                        trivy image --format json --output /vulpy/trivy-docker-image.json vulpy:latest || true
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed.'
            
            // Archive all reports
            archiveArtifacts artifacts: '**/*.html,**/*.json', 
                             allowEmptyArchive: true,
                             fingerprint: true
            
            // Copy reports to workspace for artifact storage
            sh '''
                if [ -f /vulpy/bandit-bad.html ]; then
                    cp /vulpy/bandit-bad.html . || true
                fi
                if [ -f /vulpy/bandit-good.html ]; then
                    cp /vulpy/bandit-good.html . || true
                fi
                cp /vulpy/trivy-*.json . 2>/dev/null || true
            '''
        }

        success {
            echo 'Pipeline executed successfully!'
        }

        failure {
            echo 'Pipeline execution failed. Check logs for details.'
        }

        unstable {
            echo 'Pipeline execution unstable. Security issues detected.'
        }
    }
}
