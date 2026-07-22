pipeline{
    
    agent none
    
    tools{
        maven 'Maven'
    }

	environment{
		AWS_REGION='us-east-1'
		AWS_ACCOUNT_ID='570232566568'
		ECR_REPO='ecr-repo/test'
		ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
	}
    
    stages{
        stage("Checkout"){
			agent {label 'test'}
            steps{
                git 'https://github.com/jenkins-docs/simple-java-maven-app.git'
            }
        }

	stage('Read Secret') {
		agent {label 'test'}
            steps {
                script {
                    def secret = sh(
                        script: '''
                        aws secretsmanager get-secret-value \
                        --secret-id test \
                        --query SecretString \
                        --output text
                        ''',
                        returnStdout: true
                    ).trim()

                    echo "Secret ${secret}"
                }
            }
        }
        
        stage('Compile'){
			agent {label 'test'}
            steps{
                sh 'mvn clean compile'
            }
        }
        
        stage('Test'){
			agent {label 'test'}
            steps{
                sh 'mvn test'
            }
        }
        
        stage('SonarQube Analysis') {
	agent {label 'SonarQube-Server'}
    steps {
		git 'https://github.com/jenkins-docs/simple-java-maven-app.git'
        withSonarQubeEnv('Sonarqube') {
            sh '''
                mvn sonar:sonar \
                -Dsonar.projectKey=Mini-Java-App
            '''
            }
        }
    }

        stage('Quality Gate') {
			agent {label 'SonarQube-Server'}
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
	
        
        stage('Package') {
			agent {label 'test'}
            steps {
                sh 'mvn package'
            }
        }

	stage('Build'){
		agent {label 'test'}
		steps{
			sh 'sudo docker build -t java-app .'
		}
	}

	stage("Scan Image"){
		agent {label 'test'}
		steps{
			sh 'sudo env TMPDIR=/var/tmp/trivy trivy image java-app:latest'
		}
	}

	stage("Push Image to ECR"){
		agent{label 'test'}
		steps{
			sh '''
			echo Tagging docker image
			docker tag java-app:latest ${ECR_REGISTRY}/${ECR_REPO}:${BUILD_NUMBER}

			aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}

			echo Pushing Image to ECR
			docker push ${ECR_REGISTRY}/${ECR_REPO}:${env.BUILD_NUMBER}
			'''
		}
	}
    }
}
