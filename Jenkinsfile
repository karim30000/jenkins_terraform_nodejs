pipeline{
    agent {label 'ec2'}
    stages{
        stage("CI"){
            steps{
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                sh """
                docker build . -f dockerfile -t karim3000/nodejsapp2     
                docker login -u ${USERNAME} -p ${PASSWORD}
                docker push karim3000/nodejsapp
                """
                }
            }
        }
        stage("CD"){
            steps{
                withCredentials([file(credentialsId: 'env', variable: 'RdsEnvVars')]) {
                sh "docker run -d --env-file \$RdsEnvVars -p 3000:3000 karim3000/nodejsapp2"
                }
            }
        }
    }
}