pipeline {
    agent any

    environment {
        DB_HOST                 = credentials('DB_HOST')
        DB_NAME                 = credentials('DB_NAME')
        DB_USER                 = credentials('DB_USER')
        DB_PASSWORD             = credentials('DB_PASSWORD')
        DOCKER_USER             = credentials('DOCKER_USER')
        DOCKER_PASS             = credentials('DOCKER_PASS')
        IMAGE_NAME              = "nachocker/my-flask-app"

        EC2_AMI                 = 'ami-04f167a56786e4b09'
        EC2_KEY_NAME            = 'flask_key'
        CONTROL_IP              = credentials('CONTROL_IP')

        AWS_ACCESS_KEY_ID       = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY   = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_REGION              = 'us-east-2'
    }

    stages {
        stage('Get Agent IP Address') {
            steps {
                script {
                    def agent_ip = sh(script: "curl -s https://checkip.amazonaws.com", returnStdout: true).trim()
                    env.AGENT_IP = agent_ip
                    echo "IP publica del agente: ${env.AGENT_IP}"
                }
            }
        }

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
                    make docker-push IMAGE_NAME=$IMAGE_NAME
                '''
            }
        }

        stage('Generate Terraform Variables') {
            steps {
                sh '''
                    make generate-tfvars \
                        EC2_AMI=$EC2_AMI \
                        EC2_KEY_NAME=$EC2_KEY_NAME \
                        DB_USER=$DB_USER \
                        DB_PASSWORD=$DB_PASSWORD \
                        DB_NAME=$DB_NAME \
                        CONTROL_IP=$CONTROL_IP \
                        AGENT_IP=$AGENT_IP
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
                    sh '''
                        make configure \
                            KEY=$KEY \
                            IMAGE=$(IMAGE_NAME) \
                            DB_NAME=$DB_NAME \
                            DB_USER=$DB_USER \
                            DB_PASSWORD=$DB_PASSWORD
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Limpiando espacio'
            sh 'make clean'
        }
        failure {
            echo 'Todo mal unu'
        }
        success {
            echo 'De pana'
        }
    }
}
