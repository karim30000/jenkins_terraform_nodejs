pipeline{
    agent {label 'ec2'}
    stages{
        stage("CI"){
            steps{
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                sh """
                docker build . -f dockerfile -t karim3000/nodejsapp3:1.3
                docker login -u ${USERNAME} -p ${PASSWORD}
                docker push karim3000/nodejsapp3:1.3
                """
                }
            }
        }
        stage("CD"){
            steps{
                sh "docker run -d --env-file /home/ubuntu/jenkins_home/output.txt -p 3000:3000 karim3000/nodejsapp3:1.3"

            }
        }
    }
}