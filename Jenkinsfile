pipeline {
    agent any

    environment {
        PATH = "${env.PATH}:/usr/local/bin"
        DOCKER_CREDENTIALS = credentials('docker-credentials') // Docker Hub username-password credentials ID
        SERVER_CREDENTIALS = credentials('server-credentials') // SSH private key credentials ID
        SERVER_IP = '35.205.110.31' // Production server IP address
        CONTAINER_NAME = 'new-prod-note-app' // Docker container name
        APP_PORT = '1010' // Application port
    }

    stages {
        stage('Set Version') {
            steps {
                script {
                    if (env.rollback_version) {
                        echo "Rollback version specified: ${env.rollback_version}"
                        env.VERSION = env.rollback_version
                    } else {
                        env.VERSION = env.GIT_TAG_NAME ?: "latest"
                    }
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
                        docker build -t $DOCKER_CREDENTIALS_USR/new-note-app:latest .
                        docker tag $DOCKER_CREDENTIALS_USR/new-note-app:latest $DOCKER_CREDENTIALS_USR/new-note-app:${env.VERSION}
                        docker push $DOCKER_CREDENTIALS_USR/new-note-app:latest
                        docker push $DOCKER_CREDENTIALS_USR/new-note-app:${env.VERSION}
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
                            docker pull $DOCKER_CREDENTIALS_USR/new-note-app:${env.VERSION}

                            echo "Stopping and removing existing container..."
                            docker stop $CONTAINER_NAME || true
                            docker rm $CONTAINER_NAME || true

                            echo "Running the new container..."
                            docker run -d --name $CONTAINER_NAME -p $APP_PORT:80 $DOCKER_CREDENTIALS_USR/new-note-app:${env.VERSION}

                            echo "Deployment completed successfully!"
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
