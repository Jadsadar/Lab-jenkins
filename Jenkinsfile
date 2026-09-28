pipeline {
    // Each stage group picks its own Docker image (node, sonar-scanner, ...).
    // reuseNode true keeps them on this node and workspace, so the agent's single
    // executor is never asked for twice (which would deadlock the build).
    agent { label 'linux-build' }

    environment {
        APP_NAME = 'taskflow-api'
        NODE_ENV = 'test'
        NPM_CONFIG_CACHE = '/tmp/.npm'
    }

    options {
        // Timeout 30 minutes: if npm ci hangs (e.g. registry/network stall) or a
        // test never finishes, the build would hold the agent's only executor
        // forever and every queued job would wait. Aborting frees the executor
        // and marks the build as failed so the problem gets noticed.
        // 30 (not 10) because SonarQube analysis and E2E add several minutes.
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {
        stage('Build & Test') {
            agent { docker { image 'node:24-alpine'; reuseNode true } }
            stages {
                stage('Install') {
                    steps {
                        echo "App: ${env.APP_NAME}, Env: ${env.NODE_ENV}"
                        dir('backend/api') { sh 'npm ci' }
                    }
                }
                stage('Lint') {
                    steps { dir('backend/api') { sh 'npm run lint' } }
                }
                stage('Unit Test') {
                    // test:cov = vitest run --coverage: writes reports/junit.xml and coverage/*
                    steps { dir('backend/api') { sh 'npm run test:cov' } }
                }
            }
        }
        stage('SonarQube Analysis') {
            // Scanner 5.0 matches the SonarQube 9.9 LTS server; settings live in
            // backend/api/sonar-project.properties
            agent { docker { image 'sonarsource/sonar-scanner-cli:5.0'; reuseNode true } }
            steps {
                withSonarQubeEnv('SonarQube') {
                    // SonarQube 9.9 authenticates with sonar.login (sonar.token is 10.0+)
                    dir('backend/api') { sh 'sonar-scanner -Dsonar.login=$SONAR_AUTH_TOKEN' }
                }
            }
        }
        stage('Quality Gate') {
            steps {
                // Waits for SonarQube's webhook; fails the build if the gate fails
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('Deploy Staging') {
            when { branch 'develop' }
            steps { sh 'echo deploying to staging...' }
        }
        stage('Deploy Production') {
            when { branch 'main' }
            input { message 'Deploy to production?' }
            steps { sh 'echo deploying to production...' }
        }
    }

    post {
        success { echo "SUCCESS: ${env.APP_NAME} passed on ${env.NODE_ENV}" }
        failure { echo "FAILED at stage: ${env.STAGE_NAME}" }
        always {
            archiveArtifacts artifacts: 'backend/api/npm-debug.log*', allowEmptyArchive: true
            // allowEmptyResults: a build that fails before Unit Test has no report yet
            junit testResults: 'backend/api/reports/junit.xml', allowEmptyResults: true
            recordCoverage tools: [[parser: 'COBERTURA', pattern: 'backend/api/coverage/cobertura-coverage.xml']],
                           sourceDirectories: [[path: 'backend/api']]
        }
    }
}
