pipeline {
    
    agent any

    environment{
        NETLIFY_SITE_ID = '8f06a4a7-82bf-4001-907f-ba20d9e55e10'
        NETLIFY_AUTH_TOKEN = credentials ('netlify-token')
    }

    stages {

        stage ('Docker'){
            steps{
                sh '''
                echo "Building Docker image..."
                docker build -t my-playwright .
                '''
            }
        }
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
                    node --version
                    npm --version
                    npm ci
                    npm run build
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
                            image 'my-playwright'
                            reuseNode true
                        }
                    }

                    steps{
                        sh'''
                            npm audit fix --force
                        '''
                    }
                }
            }
        }

        stage('Deploy and test in UAT'){
            agent{
                docker{
                    image 'my-playwright'
                    reuseNode true
                }
            }

            steps{
                sh'''

                echo "Deploying to UAT and writing the output into JSON. Site: $NETLIFY_SITE_ID"
                netlify deploy --dir=build --json > deploy-output.json

                echo "Reading URL from deploy-output.json"                
                node-jq -r '.deploy_url' deploy-output.json

                echo "UAT tests completed"

                sleep 3
                '''
            }
        } 
/*
        stage('Approve'){
            steps{
                timeout(1){
                    // waiting for 1 minute before abortion
                    input 'Proceed?'
                }
            }
        }
*/
        stage('Deploy and test in PROD'){
            agent{
                docker{
                    image 'my-playwright'
                    reuseNode true
                }
            }

        environment{
            CI_ENVIRONMENT_URL = 'https://funny-sundae-fee54e.netlify.app'
        }
            steps{
                sh'''
                echo "Deploying to production. Site: $NETLIFY_SITE_ID"
                netlify deploy --dir=build --prod --json

                npx playwright test
                echo "PROD tests completed"
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