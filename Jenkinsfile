pipeline {
    agent any

    environment {
        AWS_CREDENTIALS = credentials('aws-credentials')
        ECR_REPO_URI = '903655155088.dkr.ecr.ap-south-1.amazonaws.com/my-simple-app'
        AWS_REGION = 'ap-south-1'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/sanjaykarde/my-simple-app.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${env.ECR_REPO_URI}:${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO_URI}
                '''
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                script {
                    dockerImage.push("${env.BUILD_NUMBER}")
                    dockerImage.push("latest")
                }
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                terraform plan -var "ecr_repo_uri=${ECR_REPO_URI}" -var "build_number=${BUILD_NUMBER}" -out tfplan
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply tfplan'
            }
        }

        stage('Deploy to ECS') {
            steps {
                sh '''
                aws ecs update-service --cluster my-simple-app-cluster \
                --service my-simple-app-service \
                --force-new-deployment \
                --region $AWS_REGION
                '''
            }
        }
    }
}

