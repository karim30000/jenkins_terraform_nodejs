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


ssh -o ProxyCommand="ssh -i /var/jenkins_home/test.pem -W %h:%p ubuntu@54.162.224.244" -i /var/jenkins_home/test.pem ubuntu@172.31.56.220

ssh -o ProxyCommand="ssh -i /var/jenkins_home/test.pem -W %h:%p ubuntu@54.162.224.244" -i /var/jenkins_home/test.pem ubuntu@172.31.56.220 java  -jar /home/ubuntu/jenkins_home/remoting.jar -workDir /home/ubuntu/jenkins_home -jar-cache /home/ubuntu/jenkins_home/remoting/jarCache

ssh -o ProxyCommand="ssh -i /var/jenkins_home/test.pem -W %h:%p ubuntu@54.162.224.244" -i /var/jenkins_home/test.pem ubuntu@172.31.56.220 java  -jar /home/ubuntu/jenkins_home/remoting.jar