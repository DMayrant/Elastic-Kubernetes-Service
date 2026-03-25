pipeline { 
    agent any 

    environment {
        AWS_MAX_ATTEMPTS = '1'
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'us-east-1'
    }
 
    parameters {
        choice(
             name: 'ACTION',
             choices: ['apply', 'destroy', 'plan'],
             description: 'Choose Terraform action'
        )
    }

    stages {    
        stage ('Checkout') {
            steps {
                checkout scm 
            }
        }
        stage ('Check Terraform files') {
            steps {
                sh '''
                echo "Terraform files:"
                find . -name "*.tf"
                '''
            }
        }
        stage ('Debug Workspace') {
            steps {
                sh '''
                echo '==DEBUG=='
                echo 'PWD:'
                pwd

                echo 'FILES'
                ls -lah
                '''
            }
        }
        stage ('Debug Files') {
            steps {
                sh '''
                echo "=== CURRENT DIR ==="
                pwd

                echo "=== FILES ==="
                ls -lah

                echo "=== RECURSIVE ==="
                find . -name "*.json"
                '''
            }
        }
        stage ('Terraform Version') {
            steps {
                sh '''
                terraform version
                '''
            }
        }
        stage ('Terraform format') {
            when {
                expression { params.ACTION == 'apply' }
            }    
            steps {
                sh '''
                set -euo pipefail 

                echo 'Adjusting terraform format...'
                terraform fmt -check -recursive
                '''
            }
        }
        stage ('Terraform init') {
            steps {
                sh '''
                set -euo pipefail 

                echo 'Running Terraform init...'
                terraform init -reconfigure
                '''
            }
        }
         stage ('Checkov Scan') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh '''
                set -euo pipefail

                echo 'Running Checkov Scan...'
                echo "PWD=$(pwd)"
                find . -type f -name "*.tf" -print

                docker run --rm \
                  --workdir /iac \
                  -u "$(id -u):$(id -g)" \
                -v "$(pwd):/iac" \
                bridgecrew/checkov:latest \
                -d /iac \
                --framework terraform \
                --download-external-modules true \
                --evaluate-variables true \
                --output cli \
                --output json \
                --output-file-path /iac/checkov-report.json
                    
                '''
            }
        }
        stage ('Tfsec Scan') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh '''
                set -euo pipefail 
                set -euo pipefail

                echo 'Running Tfsec scan...'
                echo "PWD=$(pwd)"
                find . -type f -name "*.tf" -print

                docker run --rm \
                  --workdir /iac \
                  -u "$(id -u):$(id -g)" \
                  -v "$(pwd):/iac" \
                  aquasec/tfsec /iac \
                  --format json \
                  --out /iac/tfsec-report.json
                '''
            }
        }
        stage ('Terraform validate') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh '''
                set -euo pipefail 

                echo 'Validating Terraform configuration...'

                terraform validate
                '''
            }
        } 
        stage ('Terraform plan') {
            when {
                expression { params.ACTION == 'apply' || params.ACTION == 'plan' }     
            }
            steps {
                sh '''
                set -euo pipefail 

                echo 'Checking terraform infrastructure...'
                terraform plan -out=tfplan
                '''
            }
        }
        stage ('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {       
                sh '''
                set -euo pipefail 

                echo 'Applying terraform infrastructure'
                terraform apply -auto-approve tfplan
                '''
            }
        }
        stage ('Configure Kubectl for EKS') {
           when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh '''
                set -euo pipefail 

                echo 'Configuring kubeconfig for EKS...'

                aws eks update-kubeconfig \
                --region $AWS_DEFAULT_REGION \
                --name eks-dev

                kubectl get nodes
                '''
            }
        }
        stage ('Manifest Scaffold') {
            when {
                expression { params.ACTION == 'apply' }
            } 
            steps {
                sh '''
                set -euo pipefail

                kubectl create deployment nginx-deploy --image=nginx:1.28.0 \
                --port=80 --replicas=5 --dry-run=client -o yaml > nginx-deploy.yaml

                kubectl expose deployment nginx-deploy --port=80 --type=ClusterIP \
                --dry-run=client -o yaml > nginx-svc.yaml

                kubectl run curl --image=curlimages/curl:7.83.0 \
                --dry-run=client -o yaml > curl.yaml

                '''
            }
        }
        stage ('Deployment') {
            when {
                expression { params.ACTION == 'apply' }
            } 
            steps {
                sh '''
                set -euo pipefail 

                kubectl apply -f nginx-deploy.yaml
                kubectl apply -f nginx-svc.yaml
                kubectl apply -f curl.yaml
                '''
            }
        }
        stage ('Health Check') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh '''
                set -euo pipefail

                kubectl rollout status deployment nginx-deploy 
                kubectl rollout history deployment nginx-deploy
                kubectl logs deployment/nginx-deploy
                '''
            }
        }
        stage ('OWASP ZAP scan') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh'''
                kubectl port-forward svc/nginx-deploy 3000:80
                PF_PID=$!

                echo 'Running ZAP scan...'

                docker run --rm \
                -t owasp/zap2docker-stable zap-baseline.py \
                -t http://localhost:3000 \
                -r zap-report.html || true
                kill $PF_PID
                '''
            }
        }
        stage ('Kube-bench Scan') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh '''
                set -euo pipefail 

                echo 'Running Kube-bench...'
                
                docker run --rm \
                --pid=host \
                -v /etc:/etc:ro \
                -v /var:/var:ro \
                -v /usr:/usr:ro \
                -v /boot:/boot:ro \
                aquasec/kube-bench:latest \
                --json > kube-bench.json || true
                '''
            }
        }
        stage ('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                sh '''
                set -euo pipefail 

                echo 'Destroying terraform infrastructure and resources...'
                terraform destroy -auto-approve
                '''
            }
        }
        stage ('Archive Reports') {
            steps {
                sh '''
                echo "=== VERIFY ARTIFACTS ==="
                pwd
                ls -lah
                find . -name "*.json" || true
                '''
                archiveArtifacts artifacts: '**/*.json', allowEmptyArchive: true
                archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true
            }
        }
    }
    post {   
        success {
            echo 'Pipeline executed successful ✅'
        }
        failure {
            echo 'Pipeline failed, please check Jenkins logs 🚫'
        }
    }
}