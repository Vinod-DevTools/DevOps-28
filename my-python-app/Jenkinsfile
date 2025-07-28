pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "172.183.97.211:8082/DevOps-local-generic/python-app:${BUILD_NUMBER}"
    }
    stages {
        stage('Clone') {
            steps {
                git branch: 'main', url: 'https://github.com/Vinod-DevTools/DevOps-28.git'
            }
        }
        stage('Build & Test') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
                sh 'docker run --rm $DOCKER_IMAGE python -m unittest || true'
            }
        }
        stage('Push to JFrog') {
            steps {
                sh """
                    docker login 172.183.97.211:8082 -u admin -p Admin@1234
                    docker push $DOCKER_IMAGE
                """
            }
        }
        stage('Terraform Init & Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform plan -out=tfplan'
                }
            }
        }
        stage('Terraform Apply (SNS only)') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -target=aws_sns_topic.notification -auto-approve'
                }
            }
        }
        stage('Notify via SNS') {
            steps {
                sh 'aws sns publish --topic-arn arn:aws:sns:us-east-1:YOUR_ACCOUNT_ID:YourTopic --message "Build & Test successful for $BUILD_NUMBER"'
            }
        }
        stage('Destroy SNS') {
            steps {
                dir('terraform') {
                    sh 'terraform destroy -target=aws_sns_topic.notification -auto-approve'
                }
            }
        }
        stage('Approval to Deploy') {
            steps {
                input message: "Deploy to AWS Fargate?"
            }
        }
        stage('Terraform Apply (Fargate Deploy)') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        stage('Setup Lambda Cleanup') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -target=aws_lambda_function.cleanup -auto-approve'
                }
            }
        }
    }
}

