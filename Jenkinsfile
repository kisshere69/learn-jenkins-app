pipeline {
    agent any

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
                sh'''
                npm install netlify-cli@20.1.1
                node_modules/.bin/netlify --version
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
