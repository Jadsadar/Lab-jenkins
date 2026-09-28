pipeline {
    agent {
        docker {
            image 'node:24-alpine'
            label 'linux-build'
        }
    }

    environment {
        APP_NAME = 'taskflow-api'
        NODE_ENV = 'test'
        NPM_CONFIG_CACHE = '/tmp/.npm'
    }

    options {
        // Timeout 10 minutes: if npm ci hangs (e.g. registry/network stall) or a
        // test never finishes, the build would hold the agent's only executor
        // forever and every queued job would wait. Aborting frees the executor
        // and marks the build as failed so the problem gets noticed.
        timeout(time: 10, unit: 'MINUTES')
    }

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
