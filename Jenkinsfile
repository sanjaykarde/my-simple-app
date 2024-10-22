pipeline {
    agent any

    environment {
        AWS_CREDENTIALS = credentials('aws-credentials')
        ECR_REPO_URI = '903655155088.dkr.ecr.ap-south-1.amazonaws.com/my-simple-app-repo'
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
                    // Build the Docker image using the Jenkins docker DSL
                    dockerImage = docker.build("${env.ECR_REPO_URI}:$BUILD_NUMBER")
                }
            }
        }

        stage('Login to AWS ECR and Push Image') {
            steps {
                script {
                    // Login to ECR and push the image
                    sh "aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO_URI"
                    dockerImage.push("${env.BUILD_NUMBER}")
                    dockerImage.push("latest")
                }
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
