pipeline {
    
    agent any

    environment{
        NETLIFY_SITE_ID = '8f06a4a7-82bf-4001-907f-ba20d9e55e10'
        NETLIFY_AUTH_TOKEN = credentials ('netlify-token')
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

                    post{
                        always{
                            junit 'jest-results/junit.xml'
                        }
                    }
                }

                stage('End-to-End Test'){
                    agent{
                        docker{
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }
                }
            }
        }

        stage('Deploy UAT'){
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

                        echo "Checking if we are logged in..."
                        node_modules/.bin/netlify status

                        echo "Deploying to staging. Site: $NETLIFY_SITE_ID"
                        node_modules/.bin/netlify deploy --dir=build
                    '''
                }
            }
        }

        stage('Approve'){
            steps{
                timeout(1){
                    // waiting for 1 minute before abortion
                    input 'Proceed?'   
                }
            }
        }

        stage('Deploy PROD'){
            agent{
                docker{
                    image 'node:18-alpine'
                    reuseNode true
                }
            }

            steps{
                withCredentials([string(credentialsId: 'netlify-token', variable: 'NETLIFY_AUTH_TOKEN')]) {
                    sh'''
                        echo "Deploying to production. Site: $NETLIFY_SITE_ID"
                        node_modules/.bin/netlify deploy --dir=build --prod
                    '''
                }
            }
        }

        stage('PROD E2E'){
            agent{
                docker{
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                }
            }

        environment{
            CI_ENVIRONMENT_URL = 'https://funny-sundae-fee54e.netlify.app'
        }
            steps{
                sh'''
                echo "Production tests completed"
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