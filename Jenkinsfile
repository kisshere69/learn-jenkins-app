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

        stage('Test'){
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

        stage('End-to-End Test'){
            agent{
                docker{
                    image 'mcr.microsoft.com/playwright:v1.61.0-noble'
                    reuseNode true
                }
            }

            steps{
                sh'''
                    echo "Test stage"

                    npm install -g serve
                    serve -s build
                    npx playwright test
                    
                '''
            }
        }
    }

    post{
        always{
            junit 'test-results/junit.xml'
            archiveArtifacts artifacts: 'build/**'
        }
    }

}
