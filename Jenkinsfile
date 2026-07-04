pipeline{
    
    agent {label 'test'}
    
    tools{
        maven 'Maven'
    }
    
    stages{
        stage("Checkout"){
            steps{
                git 'https://github.com/jenkins-docs/simple-java-maven-app.git'
            }
        }
        
        stage('Compile'){
            steps{
                sh 'mvn clean compile'
            }
        }
        
        stage('Test'){
            steps{
                sh 'mvn test'
            }
        }
        
        stage('SonarQube Analysis') {
    steps {
        withSonarQubeEnv('Sonarqube') {
            sh '''
                mvn sonar:sonar \
                -Dsonar.projectKey=Mini-Java-App
            '''
            }
        }
    }

        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        
        stage('Package') {
            steps {
                sh 'mvn package'
            }
        }
    }
}
