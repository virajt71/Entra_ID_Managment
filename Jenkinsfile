pipeline {
    agent any
    
    parameters {
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Terraform action to perform'
        )
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod', 'all'],
            description: 'Environment to deploy to'
        )
    }
    
    environment {
        // Azure Credentials
        ARM_SUBSCRIPTION_ID = credentials('azure_subscription_id')
        ARM_TENANT_ID       = credentials('azure_tenant_id')
        ARM_CLIENT_ID       = credentials('azure_client_id')
        ARM_CLIENT_SECRET   = credentials('azure_client_password')
        
        // Terraform configuration
        TF_VERSION          = "1.5.0"
    }
    
    options {
        // Keep last 30 builds
        buildDiscarder(logRotator(numToKeepStr: '30'))
        // Add timestamps to console output
        timestamps()
        // Timeout after 1 hour
        timeout(time: 1, unit: 'HOURS')
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    git branch: 'develop',
                        url: 'https://github.com/virajt71/Entra_ID_Managment.git'
                }
            }
        }
        
        stage('Azure Login') {
            steps {
                script {
                    sh '''
                        az login --service-principal \
                            --username $ARM_CLIENT_ID \
                            --password $ARM_CLIENT_SECRET \
                            --tenant $ARM_TENANT_ID
                        az account set --subscription $ARM_SUBSCRIPTION_ID
                    '''
                }
            }
        }
        
        stage('Terraform Format & Validation') {
            steps {
                script {
                    sh '''
                        echo "=== Checking Terraform format across all components ==="
                        
                        # Check format without making changes
                        echo "Validating Terraform format..."
                        terraform fmt -check -recursive . || {
                            echo "ERROR: Terraform formatting issues detected. Run 'terraform fmt -recursive' to fix."
                            exit 1
                        }
                        
                        echo "✓ Terraform format validation passed"
                    '''
                }
            }
        }
        
        stage('Terraform Validation') {
            steps {
                script {
                    def components = [
                        'backend',
                        'envs/dev',
                        'envs/staging', 
                        'envs/prod',
                        'sub_managment/users',
                        'sub_managment/groups',
                        'sub_managment/rbac'
                    ]
                    
                    components.each { component ->
                        sh '''
                            echo "Validating: ''' + component + '''"
                            cd ''' + component + '''
                            terraform init -backend=false
                            terraform validate
                            cd - > /dev/null
                        '''
                    }
                    
                    echo "✓ All components passed Terraform validation"
                }
            }
        }
        
        stage('Security Scanning with tfsec') {
            steps {
                script {
                    sh '''
                        echo "=== Running security scans ==="
                        
                        # Install tfsec if not present
                        if ! command -v tfsec &> /dev/null; then
                            echo "Installing tfsec..."
                            curl -sL https://github.com/aquasecurity/tfsec/releases/download/v1.28.1/tfsec-linux-amd64 -o /tmp/tfsec
                            chmod +x /tmp/tfsec
                            TFSEC=/tmp/tfsec
                        else
                            TFSEC=tfsec
                        fi
                        
                        echo "Running tfsec checks..."
                        $TFSEC . --format json --out tfsec-report.json || true
                        
                        # Check for critical issues
                        if grep -q '"severity":"critical"' tfsec-report.json 2>/dev/null; then
                            echo "⚠ CRITICAL security issues found"
                        else
                            echo "✓ No critical security issues found"
                        fi
                        
                        # Check for secrets patterns (basic)
                        echo "Checking for potential secrets in code..."
                        if grep -r "password.*=.*['\\\"]" --include="*.tf" --include="*.csv" . | grep -v "REPLACE_WITH" | grep -v "<REPLACE" || true; then
                            echo "⚠ Review potential hardcoded passwords above"
                        fi
                    '''
                }
            }
        }
        
        stage('Plan - Backend') {
            when {
                expression { params.ENVIRONMENT == 'all' || params.ACTION == 'destroy' }
            }
            steps {
                script {
                    sh '''
                        cd backend
                        terraform init -reconfigure -backend-config=backend.hcl
                        terraform plan -out=backend.tfplan
                    '''
                }
            }
        }
        
        stage('Plan - Dev') {
            when {
                expression { params.ENVIRONMENT in ['dev', 'all'] }
            }
            steps {
                script {
                    sh '''
                        cd envs/dev
                        terraform init -reconfigure -backend-config=../../backend/backend.hcl
                        terraform plan -out=dev.tfplan
                    '''
                }
            }
        }
        
        stage('Plan - Staging') {
            when {
                expression { params.ENVIRONMENT in ['staging', 'all'] }
            }
            steps {
                script {
                    sh '''
                        cd envs/staging
                        terraform init -reconfigure -backend-config=../../backend/backend.hcl
                        terraform plan -out=staging.tfplan
                    '''
                }
            }
        }
        
        stage('Plan - Prod') {
            when {
                expression { params.ENVIRONMENT in ['prod', 'all'] }
            }
            steps {
                script {
                    sh '''
                        cd envs/prod
                        terraform init -reconfigure -backend-config=../../backend/backend.hcl
                        terraform plan -out=prod.tfplan
                    '''
                }
            }
        }
        
        stage('Plan - Users') {
            when {
                expression { params.ENVIRONMENT == 'all' }
            }
            steps {
                script {
                    sh '''
                        cd sub_managment/users
                        terraform init -reconfigure -backend-config=../../backend/backend.hcl
                        terraform plan -out=users.tfplan
                    '''
                }
            }
        }
        
        stage('Plan - Groups') {
            when {
                expression { params.ENVIRONMENT == 'all' }
            }
            steps {
                script {
                    sh '''
                        cd sub_managment/groups
                        terraform init -reconfigure -backend-config=../../backend/backend.hcl
                        terraform plan -out=groups.tfplan
                    '''
                }
            }
        }
        
        stage('Plan - RBAC') {
            when {
                expression { params.ENVIRONMENT == 'all' }
            }
            steps {
                script {
                    sh '''
                        cd sub_managment/rbac
                        terraform init -reconfigure -backend-config=../../backend/backend.hcl
                        terraform plan -out=rbac.tfplan
                    '''
                }
            }
        }
        
        stage('Approval - Production Deploy') {
            when {
                expression { params.ACTION == 'apply' && params.ENVIRONMENT in ['prod', 'all'] }
            }
            steps {
                script {
                    timeout(time: 30, unit: 'MINUTES') {
                        input '''⚠️  PRODUCTION DEPLOYMENT APPROVAL REQUIRED ⚠️
                        
This will apply changes to PRODUCTION environment.
Please review the plan output above carefully.

Do you approve this deployment?'''
                    }
                }
            }
        }
        
        stage('Terraform Init - Backend') {
            when {
                expression { params.ACTION == 'apply' && params.ENVIRONMENT in ['all'] }
            }
            steps {
                script {
                    sh '''
                        cd backend
                        terraform init -reconfigure -backend-config=backend.hcl
                        terraform apply -auto-approve
                    '''
                }
            }
        }
        stage('Terraform Init - Dev') {
            when {
                expression { params.ACTION == 'apply' && params.ENVIRONMENT in ['dev', 'all'] }
            }
            steps {
                script {
                    sh '''
                        pwd
                        cd envs/dev
                        terraform init -reconfigure -backend-config=../../backend/backend.hcl
                        terraform apply -auto-approve 
                    '''
                }
            }
        }
        stage('Terraform Init - Staging') {
            when {
                expression { params.ACTION == 'apply' && params.ENVIRONMENT in ['staging', 'all'] }
            }
            steps {
                script {
                    sh '''
                        cd envs/staging
                        terraform init -reconfigure -backend-config=../../backend/backend.hcl
                        terraform apply -auto-approve 
                    '''
                }
            }
        }
        stage('Terraform Init - Prod') {
            when {
                expression { params.ACTION == 'apply' && params.ENVIRONMENT in ['prod', 'all'] }
            }
            steps {
                script {
                    sh '''
                        cd envs/prod
                        terraform init -reconfigure -backend-config=../../backend/backend.hcl
                        terraform apply -auto-approve
                    '''
                }
            }
        }
        stage('Terraform - users') {
            when {
                expression { params.ACTION == 'apply' && params.ENVIRONMENT in ['all', 'dev', 'staging', 'prod'] }
            }
            steps {
                script {
                    sh '''
                        cd sub_managment/users
                        terraform init -reconfigure -backend-config=../../backend/backend.hcl
                        terraform apply -auto-approve 
                    '''
                }
            }
        }
        stage('Terraform - groups') {
            when {
                expression { params.ACTION == 'apply' && params.ENVIRONMENT in ['all', 'dev', 'staging', 'prod'] }
            }
            steps {
                script {
                    sh '''
                        cd sub_managment/groups
                        terraform init -reconfigure -backend-config=../../backend/backend.hcl
                        terraform apply -auto-approve 
                    '''
                }
            }
        }
        stage('Terraform - rbac') {
            when {
                expression { params.ACTION == 'apply' && params.ENVIRONMENT in ['all', 'dev', 'staging', 'prod'] }
            }
            steps {
                script {
                    sh '''
                        cd sub_managment/rbac
                        terraform init -reconfigure -backend-config=../../backend/backend.hcl
                        terraform apply -auto-approve 
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
                
                // Archive plans for review
                archiveArtifacts artifacts: '**/*.tfplan', allowEmptyArchive: true
                
                // Archive security scan results
                archiveArtifacts artifacts: 'tfsec-report.json', allowEmptyArchive: true
            }
        }
        success {
            echo '✓ Pipeline completed successfully!'
        }
        failure {
            echo '✗ Pipeline failed! Check logs for details.'
        }
        unstable {
            echo '⚠ Pipeline completed with warnings. Review security and format checks.'
        }
    }
}
