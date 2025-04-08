pipeline {
    agent any

    environment {
        DB_HOST        = credentials('DB_HOST')
        DB_NAME        = credentials('DB_NAME')
        DB_USER        = credentials('DB_USER')
        DB_PASSWORD    = credentials('DB_PASSWORD')
        DOCKER_USER    = credentials('DOCKER_USER')
        DOCKER_PASS    = credentials('DOCKER_PASS')
        IMAGE_NAME     = "nachocker/my-flask-app"

        EC2_AMI            = 'ami-04f167a56786e4b09'
        EC2_KEY_NAME       = 'flask_key'
        JENKINS_IP         = credentials('JENKINS_IP')
        JENKINS_PRIVATE_IP = credentials('JENKINS_PRIVATE_IP')

        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_REGION = 'us-east-2'
    }

    stages {
        stage('Get EC2 IP Address') {
            steps {
                script {
                    try {
                        def token = sh(
                            script: '''
                                curl -s -X PUT "http://169.254.169.254/latest/api/token" \
                                -H "X-aws-ec2-metadata-token-ttl-seconds: 10"
                            ''',
                            returnStdout: true
                        ).trim()

                        if (token) {
                            def privateIp = sh(
                                script: "curl -s -H \"X-aws-ec2-metadata-token: ${token}\" http://169.254.169.254/latest/meta-data/local-ipv4",
                                returnStdout: true
                            ).trim()

                            def publicIp = sh(
                                script: "curl -s -H \"X-aws-ec2-metadata-token: ${token}\" http://169.254.169.254/latest/meta-data/public-ipv4",
                                returnStdout: true
                            ).trim()

                            env.JENKINS_PRIVATE_IP = privateIp
                            env.JENKINS_IP = publicIp

                            echo "EC2 detectada"
                        }
                    } catch (Exception e) {
                        echo "No es una EC2"
                    }
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
                        JENKINS_IP=$JENKINS_IP \
                        JENKINS_PRIVATE_IP=$JENKINS_PRIVATE_IP
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
        failure {
            echo 'Todo mal unu'
        }
        success {
            echo 'De pana'
        }
    }
}
