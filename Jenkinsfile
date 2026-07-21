pipeline{
    
    agent none
    
    tools{
        maven 'Maven'
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
			sh 'docker build -t java-app .'
		}
	}
    }
}
