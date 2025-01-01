pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS = credentials('docker-credentials')
        SERVER_CREDENTIALS = credentials('server-credentials')
        SERVER_IP = '35.205.110.31'
        CONTAINER_NAME = 'new-prod-note-app'
        APP_PORT = '1010'
    }

    stages {
        stage('Set Version') {
            steps {
                script {
                    env.VERSION = env.rollback_version ?: 'latest'
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    sh """
                        echo $DOCKER_CREDENTIALS_PSW | docker login -u $DOCKER_CREDENTIALS_USR --password-stdin
                    """
                }
            }
        }

        stage('Build and Push Production Image') {
            steps {
                script {
                    sh """
                        docker buildx build --platform linux/amd64,linux/arm64 -t $DOCKER_CREDENTIALS_USR/new-note-app:latest --push .
                    """
                }
            }
        }

        stage('Deploy to Production Server') {
            steps {
                script {
                    sh """
                        ssh -i $SERVER_CREDENTIALS $SERVER_CREDENTIALS_USR@$SERVER_IP << EOF
                            echo "Pulling the Docker image..."
                            docker pull $DOCKER_CREDENTIALS_USR/new-note-app:latest

                            echo "Stopping and removing existing container..."
                            docker stop $CONTAINER_NAME || true
                            docker rm $CONTAINER_NAME || true

                            echo "Running the new container..."
                            docker run -d --name $CONTAINER_NAME -p $APP_PORT:80 $DOCKER_CREDENTIALS_USR/new-note-app:latest
                        EOF
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished!'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Please check the logs.'
        }
    }
}

