pipeline {
    agent any
    environment {
        AZURE_SUBSCRIPTION_ID = credentials('azure_subscription_id')
        AZURE_TENANT_ID = credentials('azure_tenant_id')
        AZURE_CLIENT_ID = credentials('azure_client_id')
        AZURE_CLIENT_PASSWORD = credentials('azure_client_password')
    }
    stages {
        stage('Azure Login') {
            steps {
                script {
                    sh '''
                        az login --service-principal \
                            --username $AZURE_CLIENT_ID \
                            --password $AZURE_CLIENT_PASSWORD \
                            --tenant $AZURE_TENANT_ID
                        az account set --subscription $AZURE_SUBSCRIPTION_ID
                    '''
                }
            }
        }
        stage('Checkout') {
            steps {
                script {
                    // Clone the repository
                    git branch: 'develop',
                        url: 'https://github.com/virajt71/Entra_ID_Managment.git'
                }
            }
        }
        stage('Terraform Init - Backend') {
            steps {
                script {
                    sh '''
                        cd backend
                        terraform init -reconfigure
                        terraform ${action} -auto-approve -var "subscription=$AZURE_SUBSCRIPTION_ID"
                    '''
                }
            }
        }
        stage('Terraform Init - Dev') {
            steps {
                script {
                    sh '''
                        pwd
                        cd envs/dev
                        terraform init -reconfigure
                        terraform ${action} -auto-approve -var "subscription=$AZURE_SUBSCRIPTION_ID"
                    '''
                }
            }
        }
        stage('Terraform Init - Staging') {
            steps {
                script {
                    sh '''
                        cd envs/staging
                        terraform init -reconfigure
                        terraform ${action} -auto-approve -var "subscription=$AZURE_SUBSCRIPTION_ID"
                    '''
                }
            }
        }
        stage('Terraform Init - Prod') {
            steps {
                script {
                    sh '''
                        cd envs/prod
                        terraform init -reconfigure
                        terraform ${action} -auto-approve -var "subscription=$AZURE_SUBSCRIPTION_ID"
                    '''
                }
            }
        }
        stage('Terraform - users') {
            steps {
                script {
                    sh '''
                        cd sub_managment/users
                        terraform init -reconfigure
                        terraform ${action} -auto-approve -var "subscription=$AZURE_SUBSCRIPTION_ID"
                    '''
                }
            }
        }
        stage('Terraform - groups') {
            steps {
                script {
                    sh '''
                        cd sub_managment/groups
                        terraform init -reconfigure
                        terraform ${action} -auto-approve -var "subscription=$AZURE_SUBSCRIPTION_ID"
                    '''
                }
            }
        }
        stage('Terraform - rbac') {
            steps {
                script {
                    sh '''
                        cd sub_managment/rbac
                        terraform init -reconfigure
                        terraform ${action} -auto-approve -var "subscription=$AZURE_SUBSCRIPTION_ID"
                    '''
                }
            }
        }
    }
    
    post {
        always {
            script {
                // Logout from Azure
                sh 'az logout || true'
            }
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed! Check logs for details.'
        }
    }
}
