pipeline {
    agent any

    environment {
        PATH = "${env.PATH}:/usr/local/bin"
        DOCKER_CREDENTIALS = credentials('docker-credentials')
        SERVER_CREDENTIALS = credentials('server-credentials')
        SERVER_IP = '35.205.110.31'
    }

    stages {
        stage('Set Version') {
            steps {
                script {
                    if (env.rollback_version) {
                        echo "Rollback version specified: ${env.rollback_version}"
                        env.VERSION = env.rollback_version
                    } else {
                        env.VERSION = env.GIT_TAG_NAME
                    }
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    sh 'echo $DOCKER_CREDENTIALS_PSW | docker login -u $DOCKER_CREDENTIALS_USR --password-stdin'
                }
            }
        }

        stage('Build and Push Production Image') {
            when {
                branch 'main'
            }
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
                            docker pull $DOCKER_CREDENTIALS_USR/new-note-app:${env.VERSION}
                            docker stop prod-note-app || true
                            docker rm prod-note-app || true
                            docker run -d --name prod-note-app -p 1010:80 $DOCKER_CREDENTIALS_USR/new-note-app:${env.VERSION}
                        EOF
                    """
                }
            }
        }
    }
}