pipeline {
    // Each stage group picks its own Docker image (node, sonar-scanner, ...).
    // reuseNode true keeps them on this node and workspace, so the agent's single
    // executor is never asked for twice (which would deadlock the build).
    agent { label 'linux-build' }

    parameters {
        // SonarQube, its Quality Gate and E2E are the slowest stages (~5 min together).
        // They always run on main, develop and pull requests; on other branches only when
        // this box is ticked (Build with Parameters), so feature-branch pushes get feedback faster.
        booleanParam(name: 'FULL_CHECKS', defaultValue: false,
                     description: 'Also run SonarQube, Quality Gate and E2E on this branch')
    }

    environment {
        APP_NAME = 'taskflow-api'
        NODE_ENV = 'test'
        NPM_CONFIG_CACHE = '/tmp/.npm'
        E2E_COMPOSE = '-f backend/docker-compose.e2e.yml -p petpaws-e2e'
        // Terraform providers (~100 MB for aws) are downloaded once into the tf-plugins volume
        // that every terraform container mounts, instead of on each init
        TF_PLUGIN_CACHE_DIR = '/tf-plugins'
    }

    options {
        // Timeout 30 minutes: if npm ci hangs (e.g. registry/network stall) or a
        // test never finishes, the build would hold the agent's only executor
        // forever and every queued job would wait. Aborting frees the executor
        // and marks the build as failed so the problem gets noticed.
        // 60 (not 10) because SonarQube, E2E, the Lab 06 security stages, the Lab 07
        // image build/scan/deploy and the Lab 08 IaC stages each add several minutes,
        // plus up to 15 minutes waiting for a human at the Terraform approval.
        timeout(time: 60, unit: 'MINUTES')
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
                    // npm-cache volume: packages are downloaded once and reused by every npm ci
                    agent { docker { image 'node:24-alpine'; args '-v npm-cache:/tmp/.npm'; reuseNode true } }
                    steps {
                        dir('backend/api') {
                            // --no-audit: the SCA stage runs npm audit once, no need on every install
                            sh 'npm ci --prefer-offline --no-audit --no-fund'
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
            agent { docker { image 'node:24-alpine'; args '-v npm-cache:/tmp/.npm'; reuseNode true } }
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
            // Lab 09: runs on an ephemeral Kubernetes pod in the kind cluster instead of a Docker
            // container on linux-build. The Kubernetes plugin creates the pod for this stage and
            // deletes it afterwards. node:24 (not the lab's node:20): the app needs TypeScript 6 / Vitest 4.
            agent {
                kubernetes {
                    cloud 'kind'
                    yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: node
    image: node:24-alpine
    command: ['cat']
    tty: true
    resources:
      requests: { cpu: 500m, memory: 512Mi }
'''
                    defaultContainer 'node'
                }
            }
            stages {
                stage('Install') {
                    steps {
                        echo "App: ${env.APP_NAME}, Env: ${env.NODE_ENV}"
                        dir('backend/api') { sh 'npm ci --prefer-offline --no-audit --no-fund' }
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
            post {
                always {
                    // The pod and its workspace are deleted after this stage, so hand the test and
                    // coverage reports to linux-build (SonarQube and the final junit/coverage steps read them)
                    stash name: 'test-reports', allowEmpty: true,
                          includes: 'backend/api/reports/**, backend/api/coverage/**'
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
            when {
                beforeAgent true // decide before starting the scanner container, so a skip costs nothing
                anyOf { branch 'main'; branch 'develop'; changeRequest(); expression { params.FULL_CHECKS } }
            }
            agent { docker { image 'sonarsource/sonar-scanner-cli:5.0'; reuseNode true } }
            steps {
                // Coverage (lcov) was produced on the Build & Test pod
                unstash 'test-reports'
                withSonarQubeEnv('SonarQube') {
                    // SonarQube 9.9 authenticates with sonar.login (sonar.token is 10.0+)
                    dir('backend/api') { sh 'sonar-scanner -Dsonar.login=$SONAR_AUTH_TOKEN' }
                }
            }
        }
        stage('Quality Gate') {
            // Same condition as SonarQube Analysis: there is no result to wait for otherwise
            when {
                anyOf { branch 'main'; branch 'develop'; changeRequest(); expression { params.FULL_CHECKS } }
            }
            steps {
                // Waits for SonarQube's webhook; fails the build if the gate fails
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('E2E') {
            when {
                anyOf { branch 'main'; branch 'develop'; changeRequest(); expression { params.FULL_CHECKS } }
            }
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
                    // tf-plugins volume = TF_PLUGIN_CACHE_DIR: the aws provider is downloaded once, not per init
                    agent { docker { image 'hashicorp/terraform:1.13'; args '--entrypoint="" -v tf-plugins:/tf-plugins'; reuseNode true } }
                    // Own data dir: the workspace survives between builds, and its .terraform/ remembers
                    // the S3 backend from the last Plan stage, which would make even -backend=false ask
                    // for credentials. A throwaway dir keeps this check offline and credential-free.
                    environment { TF_DATA_DIR = '/tmp/tf-validate' }
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
        stage('State Bucket') {
            // LocalStack's free edition keeps everything in memory, so a restart wipes the state
            // bucket. Recreate it (versioned) if missing; on real S3 this bucket would simply exist.
            agent { docker { image 'amazon/aws-cli:latest'; args '--entrypoint="" --network lab08'; reuseNode true } }
            steps {
                withCredentials([usernamePassword(credentialsId: 'localstack-aws',
                                                  usernameVariable: 'AWS_ACCESS_KEY_ID',
                                                  passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        export AWS_DEFAULT_REGION=us-east-1
                        S3="aws --endpoint-url http://localstack:4566 s3api"
                        $S3 head-bucket --bucket taskflow-tfstate 2>/dev/null || {
                            $S3 create-bucket --bucket taskflow-tfstate
                            $S3 put-bucket-versioning --bucket taskflow-tfstate --versioning-configuration Status=Enabled
                        }
                    '''
                }
            }
        }
        stage('Terraform Plan') {
            // --network lab08: reach LocalStack (EC2 API and the S3 state bucket) at localstack:4566
            agent { docker { image 'hashicorp/terraform:1.13'; args '--entrypoint="" --network lab08 -v tf-plugins:/tf-plugins'; reuseNode true } }
            steps {
                withCredentials([usernamePassword(credentialsId: 'localstack-aws',
                                                  usernameVariable: 'AWS_ACCESS_KEY_ID',
                                                  passwordVariable: 'AWS_SECRET_ACCESS_KEY'),
                                 string(credentialsId: 'lab08-ssh-pub', variable: 'TF_VAR_ssh_public_key')]) {
                    dir('infra/terraform') {
                        // -reconfigure: the lint stage ran init -backend=false in this same directory
                        sh 'terraform init -input=false -reconfigure'
                        sh 'terraform plan -input=false -out=tfplan'
                        sh 'terraform show -no-color tfplan > tfplan.txt'
                        script {
                            // e.g. "Plan: 3 to add, 0 to change, 0 to destroy." for the approval prompt
                            env.PLAN_SUMMARY = sh(
                                script: "grep -E '^(Plan:|No changes)' tfplan.txt || echo 'No summary line; see tfplan.txt'",
                                returnStdout: true
                            ).trim()
                        }
                    }
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'infra/terraform/tfplan, infra/terraform/tfplan.txt', allowEmptyArchive: true
                }
            }
        }
        stage('Approval') {
            // A human must read the plan and click Apply; without that, nothing is applied.
            // The timeout aborts the build instead of holding the executor forever.
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    input message: "Apply this Terraform plan?\n\n${env.PLAN_SUMMARY}\n\n" +
                                   "Full plan: ${env.BUILD_URL}artifact/infra/terraform/tfplan.txt",
                          ok: 'Apply'
                }
            }
        }
        stage('Terraform Apply') {
            agent { docker { image 'hashicorp/terraform:1.13'; args '--entrypoint="" --network lab08 -v tf-plugins:/tf-plugins'; reuseNode true } }
            steps {
                withCredentials([usernamePassword(credentialsId: 'localstack-aws',
                                                  usernameVariable: 'AWS_ACCESS_KEY_ID',
                                                  passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir('infra/terraform') {
                        // Apply the saved plan file, not a fresh plan: what was approved is exactly what runs
                        sh 'terraform apply -input=false tfplan'
                        sh 'terraform output'
                        // Read by the Ansible stage to build its inventory
                        sh 'terraform output -json > tf-outputs.json'
                    }
                }
            }
        }
        stage('Configure with Ansible') {
            agent { docker { image 'alpine/ansible:latest'; args '--entrypoint="" --network lab08'; reuseNode true } }
            environment {
                // LocalStack's free EC2 is a mock with no machine behind its IP, so SSH goes to the
                // stand-in host (infra/lab-host). Remove this line when targeting real AWS.
                TARGET_HOST_OVERRIDE = 'taskflow-vm'
                // Set here, not only in ansible.cfg: Ansible ignores a cfg in a world-writable directory.
                // The host is recreated on every apply, so its SSH host key changes each time.
                ANSIBLE_HOST_KEY_CHECKING = 'False'
            }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'lab08-ssh-key',
                                                   keyFileVariable: 'ANSIBLE_SSH_KEY',
                                                   usernameVariable: 'ANSIBLE_SSH_USER')]) {
                    // Dynamic inventory from `terraform output`, then the playbook; IMAGE is the
                    // taskflow-api tag the Build Image stage pushed
                    sh '''
                        python3 infra/ansible/inventory_from_tf.py infra/terraform/tf-outputs.json inventory.ini
                        cd infra/ansible && ansible-playbook -i ../../inventory.ini playbook.yml
                    '''
                }
            }
            post { always { archiveArtifacts artifacts: 'inventory.ini', allowEmptyArchive: true } }
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
            script {
                // Reports come from the Build & Test pod; the stash is missing if the build
                // stopped before that stage, and the junit step below already allows empty results
                try { unstash 'test-reports' } catch (err) { echo 'No test reports to collect' }
            }
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
