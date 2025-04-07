pipeline {
    agent any

    environment {
        DB_HOST        = credentials('DB_HOST')
        DB_NAME        = credentials('DB_NAME')
        DB_USER        = credentials('DB_USER')
        DB_PASSWORD    = credentials('DB_PASSWORD')
        SSH_PRIVATE_KEY = credentials('SSH_PRIVATE_KEY')
        DOCKER_USER    = credentials('DOCKER_USER')
        DOCKER_PASS    = credentials('DOCKER_PASS')
        IMAGE_NAME     = "nachocker/my-flask-app"

        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_REGION = 'us-east-2'
    }

    stages {
        stage('Clone Repo') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'make docker-build'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'make test'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    make docker-push IMAGE=$(IMAGE_NAME)
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'make infra'
            }
        }

        stage('Configure EC2 with Ansible') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ec2_ssh_key', keyFileVariable: 'KEY')]) {
                    sh 'make configure KEY=$KEY IMAGE=$(IMAGE_NAME)'
                }
            }
        }
    }

    post {
        failure {
            echo 'Todo mal unu'
        }
        success {
            echo 'De pana'
        }
    }
}
