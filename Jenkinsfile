pipeline {
    // Each stage group picks its own Docker image (node, sonar-scanner, ...).
    // reuseNode true keeps them on this node and workspace, so the agent's single
    // executor is never asked for twice (which would deadlock the build).
    agent { label 'linux-build' }

    environment {
        APP_NAME = 'taskflow-api'
        NODE_ENV = 'test'
        NPM_CONFIG_CACHE = '/tmp/.npm'
        E2E_COMPOSE = '-f backend/docker-compose.e2e.yml -p petpaws-e2e'
    }

    options {
        // Timeout 30 minutes: if npm ci hangs (e.g. registry/network stall) or a
        // test never finishes, the build would hold the agent's only executor
        // forever and every queued job would wait. Aborting frees the executor
        // and marks the build as failed so the problem gets noticed.
        // 45 (not 10) because SonarQube, E2E, the Lab 06 security stages and the Lab 07
        // image build/scan/deploy each add several minutes.
        timeout(time: 45, unit: 'MINUTES')
    }

    stages {
        stage('Secrets Detection') {
            // Runs first: a leaked secret should stop the build before anything else runs.
            // The image's entrypoint is gitleaks itself; clearing it lets Jenkins run its own commands.
            agent { docker { image 'zricethezav/gitleaks:latest'; args '--entrypoint=""'; reuseNode true } }
            steps {
                // HOME must be writable for git config; safe.directory avoids "dubious ownership"
                // because the container user differs from the workspace owner
                sh '''
                    export HOME=/tmp
                    git config --global --add safe.directory "$PWD"
                    # Gitleaks scans history, so a shallow clone would hide older commits
                    if [ "$(git rev-parse --is-shallow-repository)" = "true" ]; then
                        git fetch --unshallow || true
                    fi
                    gitleaks detect --source . --log-opts="--all" \
                        --report-format json --report-path gitleaks-report.json \
                        --redact --exit-code 1 --verbose
                '''
            }
            post {
                // Archive on failure too: that is when the report matters most
                always { archiveArtifacts artifacts: 'gitleaks-report.json', allowEmptyArchive: true }
            }
        }
        stage('SAST') {
            // Static analysis before the build; both tools are independent, so they run in parallel
            parallel {
                stage('ESLint Security') {
                    agent { docker { image 'node:24-alpine'; reuseNode true } }
                    steps {
                        dir('backend/api') {
                            sh 'npm ci'
                            // Rules come from eslint.config.js; errors fail the stage, warnings are reported only
                            sh 'npx eslint --plugin security src/'
                        }
                    }
                }
                stage('Semgrep') {
                    agent { docker { image 'semgrep/semgrep:latest'; args '--entrypoint=""'; reuseNode true } }
                    steps {
                        dir('backend/api') {
                            // HOME=/tmp: Jenkins runs the container as its own uid, which can't write to the image's HOME
                            sh '''
                                export HOME=/tmp
                                semgrep scan --config p/owasp-top-ten --config p/nodejs \
                                    --sarif --output semgrep.sarif --metrics=off src/
                            '''
                        }
                    }
                    post {
                        always { archiveArtifacts artifacts: 'backend/api/semgrep.sarif', allowEmptyArchive: true }
                    }
                }
            }
        }
        stage('SCA - npm audit') {
            // Dependency scan before the build. Policy: critical blocks, high only warns.
            agent { docker { image 'node:24-alpine'; reuseNode true } }
            steps {
                dir('backend/api') {
                    // npm audit exits non-zero whenever it finds anything, so ignore its exit code
                    // and decide from the severity counts in the JSON instead
                    sh 'npm audit --json > audit.json || true'
                    script {
                        // node instead of jq: node:24-alpine has no jq
                        // Plain indexing: Jenkins' CPS Groovy rejects the spread operator and multiple assignment
                        def counts = sh(
                            script: '''node -e "const v = require('./audit.json').metadata.vulnerabilities; console.log([v.critical, v.high, v.moderate, v.low].join(' '))"''',
                            returnStdout: true
                        ).trim().split(' ')
                        def critical = counts[0].toInteger()
                        def high = counts[1].toInteger()
                        def moderate = counts[2].toInteger()
                        def low = counts[3].toInteger()
                        echo "npm audit: critical=${critical} high=${high} moderate=${moderate} low=${low}"
                        if (critical > 0) {
                            // Marks this stage and the build FAILED (so it can never go green or deploy),
                            // but lets the pipeline reach the Policy Gate, which then stops it for good.
                            // Two independent checks: the block still holds if either one is misconfigured.
                            catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                                error("Blocking: ${critical} critical vulnerabilities found")
                            }
                        } else {
                            if (high > 0) {
                                unstable("Warning: ${high} high vulnerabilities found (not blocking)")
                            }
                            echo "SCA passed with 0 critical vulnerabilities (warnings allowed)"
                        }
                    }
                }
            }
            post {
                always { archiveArtifacts artifacts: 'backend/api/audit.json', allowEmptyArchive: true }
            }
        }
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
        stage('Generate SBOM') {
            // After the build: the SBOM describes the release artifact's dependencies
            stages {
                stage('SBOM: Syft') {
                    // :debug is the only syft image with a shell (the default one is distroless);
                    // its binary lives at /syft, outside PATH
                    agent { docker { image 'anchore/syft:debug'; args '--entrypoint=""'; reuseNode true } }
                    steps {
                        // Components come from package-lock.json; skipping node_modules avoids scanning them twice
                        sh '''
                            /syft scan dir:backend/api --exclude ./node_modules \
                                --source-name taskflow-api --source-version "${GIT_COMMIT}" \
                                -o cyclonedx-json=sbom.cdx.json
                        '''
                    }
                }
                stage('SBOM: Cosign Sign') {
                    // -dev tag: same cosign build plus a shell, which Jenkins needs to run steps
                    agent { docker { image 'ghcr.io/sigstore/cosign/cosign:v2.6.1-dev'; args '--entrypoint=""'; reuseNode true } }
                    steps {
                        withCredentials([file(credentialsId: 'cosign-key', variable: 'COSIGN_KEY'),
                                         string(credentialsId: 'cosign-pass', variable: 'COSIGN_PASSWORD')]) {
                            // --tlog-upload=false: keep the signature local instead of publishing it
                            // to the public Rekor transparency log
                            sh '''
                                cosign sign-blob --yes --key "$COSIGN_KEY" --tlog-upload=false \
                                    --output-signature sbom.cdx.json.sig sbom.cdx.json
                                cosign verify-blob --key cosign.pub --insecure-ignore-tlog=true \
                                    --signature sbom.cdx.json.sig sbom.cdx.json
                            '''
                        }
                    }
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'sbom.cdx.json, sbom.cdx.json.sig, cosign.pub',
                                     allowEmptyArchive: true, fingerprint: true
                }
            }
        }
        stage('Policy Gate') {
            // OPA decides from npm audit's report using policy/security.rego.
            // :latest-debug has a shell; the plain opa image does not.
            agent { docker { image 'openpolicyagent/opa:latest-debug'; args '--entrypoint=""'; reuseNode true } }
            steps {
                // Unit tests first, so a broken policy cannot silently let builds through
                sh 'opa test policy/ -v'
                // --fail-defined: exit 1 when the query returns any deny message, 0 when it returns none
                sh '''
                    opa eval --format pretty -i backend/api/audit.json -d policy/security.rego "data.security.warn"
                    opa eval --fail-defined --format pretty -i backend/api/audit.json -d policy/security.rego \
                        "data.security.deny[msg]"
                '''
                echo 'Policy Gate passed: no deny rules fired'
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
        stage('E2E') {
            stages {
                stage('E2E: Start Stack') {
                    // Runs on linux-build itself (it has the docker CLI); --wait blocks
                    // until postgres, minio and the api pass their healthchecks
                    steps { sh "docker compose ${E2E_COMPOSE} up -d --build --wait" }
                }
                stage('E2E: Playwright') {
                    // Headless run joined to the stack's network, so http://api:3000 resolves
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.63.0-noble'
                            args '--network petpaws-e2e_default'
                            reuseNode true
                        }
                    }
                    environment { API_BASE_URL = 'http://api:3000' }
                    steps { dir('backend/e2e') { sh 'npm ci && npx playwright test' } }
                }
            }
        }
        stage('Build Image') {
            // Immutable tag from the commit SHA, never `latest`, so every deploy maps back to exact source.
            // The localhost:5001 prefix is the local registry:2 container (kind-registry).
            steps {
                script {
                    env.IMAGE = "localhost:5001/taskflow-api:${env.GIT_COMMIT.take(7)}"
                }
                sh 'docker build -t "$IMAGE" backend/api'
                sh 'docker push "$IMAGE"'
            }
        }
        stage('Container Scan') {
            // Scans the image built above. docker.sock lets Trivy read it straight from the daemon;
            // the trivy-cache volume keeps the vulnerability DB between builds so it isn't re-downloaded
            agent {
                docker {
                    image 'aquasec/trivy:latest'
                    args '--entrypoint="" -v /var/run/docker.sock:/var/run/docker.sock -v trivy-cache:/root/.cache'
                    reuseNode true
                }
            }
            steps {
                // First run always writes the SARIF report; the second is the gate (exit 1 on HIGH/CRITICAL)
                // and prints the findings table to the console
                sh '''
                    trivy image --format sarif --output trivy.sarif --severity HIGH,CRITICAL "$IMAGE"
                    trivy image --exit-code 1 --severity HIGH,CRITICAL "$IMAGE"
                '''
            }
            post {
                // Archive regardless of outcome: a blocked build is when the report matters most
                always { archiveArtifacts artifacts: 'trivy.sarif', allowEmptyArchive: true }
            }
        }
        stage('Blue/Green Deploy') {
            // kubectl runs in alpine/k8s; --network kind lets it reach the cluster API at
            // taskflow-control-plane:6443 (the address in the kind-kubeconfig credential)
            agent { docker { image 'alpine/k8s:1.31.4'; args '--entrypoint="" --network kind'; reuseNode true } }
            environment { KUBECONFIG = credentials('kind-kubeconfig') }
            steps {
                script {
                    // env.* rather than def: post { failure } below needs CURRENT to roll back
                    env.CURRENT = sh(
                        script: "kubectl get svc taskflow -o jsonpath='{.spec.selector.color}'",
                        returnStdout: true
                    ).trim()
                    env.NEXT = env.CURRENT == 'blue' ? 'green' : 'blue'
                    echo "Live color: ${env.CURRENT}, deploying ${env.IMAGE} to ${env.NEXT}"

                    sh "kubectl set image deployment/taskflow-${env.NEXT} app=${env.IMAGE}"
                    // --timeout: a broken image fails the stage instead of hanging the build
                    sh "kubectl rollout status deployment/taskflow-${env.NEXT} --timeout=120s"

                    // smoke test the new pods directly, bypassing the Service
                    sh "kubectl delete pod smoke-${BUILD_NUMBER} --ignore-not-found"
                    sh "kubectl run smoke-${BUILD_NUMBER} --rm -i --restart=Never --image=curlimages/curl -- " +
                       "curl -sf http://taskflow-${env.NEXT}:8080/health"

                    sh "kubectl patch svc taskflow -p '{\"spec\":{\"selector\":{\"color\":\"${env.NEXT}\"}}}'"
                    echo "Switched traffic from ${env.CURRENT} to ${env.NEXT}"
                }
            }
            post {
                // Automated rollback: point the Service back at the color that was live before this build.
                // Stage-level post because it needs this stage's kubectl container and credential.
                failure {
                    script {
                        if (env.CURRENT) {
                            sh "kubectl patch svc taskflow -p '{\"spec\":{\"selector\":{\"color\":\"${env.CURRENT}\"}}}'"
                            echo "ROLLBACK: traffic restored to ${env.CURRENT}"
                        }
                    }
                }
            }
        }
        stage('IaC Lint & Validate') {
            // Offline checks only: -backend=false skips the S3 state, so no LocalStack needed here
            parallel {
                stage('Terraform Validate') {
                    agent { docker { image 'hashicorp/terraform:1.13'; args '--entrypoint=""'; reuseNode true } }
                    steps {
                        dir('infra/terraform') {
                            sh 'terraform init -backend=false'
                            sh 'terraform validate'
                            sh 'terraform fmt -check -recursive'
                        }
                    }
                }
                stage('Ansible Lint') {
                    agent { docker { image 'pipelinecomponents/ansible-lint:latest'; args '--entrypoint=""'; reuseNode true } }
                    steps { sh 'ansible-lint infra/ansible/playbook.yml' }
                }
            }
        }
        stage('IaC Security Scan') {
            // Both tools exit non-zero on any failed check, so either one blocks the pipeline.
            // Findings that don't apply are skipped inline in the .tf files, each with a reason.
            parallel {
                stage('tfsec') {
                    agent { docker { image 'aquasec/tfsec:latest'; args '--entrypoint=""'; reuseNode true } }
                    steps {
                        // First run only writes the SARIF report; the second is the gate and prints the table
                        sh '''
                            tfsec infra/terraform --format sarif --out tfsec.sarif --soft-fail
                            tfsec infra/terraform --no-color
                        '''
                    }
                    post { always { archiveArtifacts artifacts: 'tfsec.sarif', allowEmptyArchive: true } }
                }
                stage('checkov') {
                    agent { docker { image 'bridgecrew/checkov:latest'; args '--entrypoint=""'; reuseNode true } }
                    steps {
                        sh '''
                            checkov -d infra/terraform --framework terraform --compact \
                                -o cli -o sarif --output-file-path console,checkov.sarif
                        '''
                    }
                    post { always { archiveArtifacts artifacts: 'checkov.sarif', allowEmptyArchive: true } }
                }
            }
        }
        stage('Deploy Staging') {
            when { branch 'develop' }
            steps { sh 'echo deploying to staging...' }
        }
        stage('Deploy Production') {
            // beforeInput: check the branch before prompting, so other branches skip without waiting
            when {
                beforeInput true
                branch 'main'
            }
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
            junit testResults: 'backend/e2e/results/e2e-junit.xml', allowEmptyResults: true
            archiveArtifacts artifacts: 'backend/e2e/playwright-report/**', allowEmptyArchive: true
            publishHTML target: [reportName: 'Playwright Report', reportDir: 'backend/e2e/playwright-report',
                                 reportFiles: 'index.html', keepAll: true, allowMissing: true, alwaysLinkToLastBuild: true]
            // Always tear the stack down, even when tests fail, so the next build starts clean
            sh "docker compose ${E2E_COMPOSE} down -v || true"
        }
    }
}
