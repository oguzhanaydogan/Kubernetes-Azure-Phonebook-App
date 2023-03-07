pipeline {
    agent any
    tools {
        terraform 'terraform'
    }

    environment {
        AWS_REGION = "us-east-1"
        AWS_ACCOUNT_ID = sh(script:'export PATH="$PATH:/usr/local/bin" && aws sts get-caller-identity --query Account --output text', returnStdout:true).trim()
    }

    stages {
        stage('Create Infrastructure for the App') {
            steps {
                dir('/var/lib/jenkins/workspace/Jenkins-project/eks-terraform'){
                    echo 'Creating Infrastructure for the App on AWS Cloud'
                    sh 'terraform init'
                    sh 'terraform apply --auto-approve'
                }
            }
        }
        stage('Connect to EKS') {
            steps {
                dir('/var/lib/jenkins/workspace/Jenkins-project/eks-terraform'){
                    echo 'Injecting Terraform Output into connection command'
                    script {
                        env.EKS_NAME = sh(script: 'terraform output -raw eks_name', returnStdout:true).trim()
                    }
                    sh 'aws eks update-kubeconfig --name=${EKS_NAME}'
                }
            }
        }
        stage('Deploy K8s files') {
            steps {
                dir('/var/lib/jenkins/workspace/Jenkins-project/k8s') {
                    sh 'kubectl apply -f .'
                }
            }
        }
        stage('Destroy the Infrastructure') {
            steps{
                timeout(time:5, unit:'DAYS'){
                    input message:'Do you want to terminate?'
                }
                dir('/var/lib/jenkins/workspace/Jenkins-project/eks-terraform'){
                    sh """
                    terraform destroy --auto-approve
                    """
                }
            }
        }
    }
}