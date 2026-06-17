pipeline {
    agent any

    environment{
        NETLIFY_SITE_ID = '8f06a4a7-82bf-4001-907f-ba20d9e55e10'
        JENKINS_AUTH_TOKEN = credentials ('netlify-token')
    }

    stages {
        stage('Build') {
            agent{
                docker{
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            
            steps {
                sh '''
                    echo "Listing files..." 
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        }

        stage('Parallel Tests'){
            parallel{
                stage('Unit Test'){
                    agent{
                        docker{
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }

                    steps{
                        sh'''
                        echo "Test stage"
                        test -f build/index.html

                        echo "Testing npm"
                        npm test
                        '''
                    }
                }             
            }
        }

        stage('Deploy'){
            agent{
                docker{
                    image 'node:18-alpine'
                    reuseNode true
                }
            }

            steps{
                withCredentials([string(credentialsId: 'netlify-token', variable: 'NETLIFY_AUTH_TOKEN')]) {
                    sh'''
                        npm install netlify-cli@20.1.1
                        node_modules/.bin/netlify --version
                        echo "Deploying to PROD. Site: $NETLIFY_SITE_ID"
                        node_modules/.bin/netlify status
                    '''
                }
            }

        }

    /*
    post{
        always{
            junit 'test-results/junit.xml'
            archiveArtifacts artifacts: 'build/**'
        }
    }
    */

}
