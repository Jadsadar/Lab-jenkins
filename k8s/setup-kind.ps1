# Lab 07 Task 3: one-time local setup for the Blue/Green lab.
# Run from the repo root in PowerShell:   powershell -ExecutionPolicy Bypass -File k8s\setup-kind.ps1
#
# Creates: registry:2 container (kind-registry, localhost:5001), kind cluster "taskflow"
# wired to pull from it, the taskflow-env Secret with random passwords, a bootstrap image,
# Postgres + MinIO, the blue/green Deployments and Services, and kind-kubeconfig.yaml
# for the Jenkins credential. Safe to re-run: existing pieces are reused.

$ErrorActionPreference = 'Stop'
$Registry = 'kind-registry'
$Cluster = 'taskflow'
$Node = "$Cluster-control-plane"

function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }

# Native commands don't throw on failure in PowerShell 5.1, so check exit codes explicitly
function Run {
    & $args[0] $args[1..($args.Count - 1)]
    if ($LASTEXITCODE -ne 0) { throw "Command failed ($LASTEXITCODE): $($args -join ' ')" }
}

# Random URL-safe secret (hex), so it can go straight into DATABASE_URL
function New-Secret {
    $bytes = New-Object byte[] 24
    [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    ($bytes | ForEach-Object { $_.ToString('x2') }) -join ''
}

Step 'Checking tools'
foreach ($tool in 'docker', 'kind', 'kubectl') {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        throw "$tool not found. Install kind with: winget install Kubernetes.kind (then reopen PowerShell)"
    }
}

Step "Local registry ($Registry on localhost:5001)"
if (-not (docker ps -a --filter "name=^$Registry$" --format '{{.Names}}')) {
    Run docker run -d --restart=always -p 127.0.0.1:5001:5000 --name $Registry registry:2
} else {
    Run docker start $Registry | Out-Null
    Write-Host 'already exists'
}

Step "kind cluster ($Cluster)"
if ((kind get clusters) -notcontains $Cluster) {
    Run kind create cluster --config k8s/kind-config.yaml
} else {
    Write-Host 'already exists'
}
Run kubectl config use-context "kind-$Cluster"

Step 'Pointing the node at the registry (localhost:5001 -> kind-registry:5000)'
Run docker exec $Node mkdir -p /etc/containerd/certs.d/localhost:5001
'[host."http://kind-registry:5000"]' | docker exec -i $Node sh -c 'cat > /etc/containerd/certs.d/localhost:5001/hosts.toml'
if ($LASTEXITCODE -ne 0) { throw 'Could not write hosts.toml on the kind node' }
# Joining an already-joined network is an error, so check first
$networks = docker inspect $Registry --format '{{json .NetworkSettings.Networks}}'
if ($networks -notmatch '"kind"') { Run docker network connect kind $Registry }

Step 'Secret taskflow-env (random values, never written to disk)'
# PowerShell 5.1 turns redirected native stderr into a terminating error under 'Stop'
$ErrorActionPreference = 'Continue'
kubectl get secret taskflow-env 2>$null | Out-Null
$secretMissing = $LASTEXITCODE -ne 0
$ErrorActionPreference = 'Stop'
if ($secretMissing) {
    $pg = New-Secret
    Run kubectl create secret generic taskflow-env `
        "--from-literal=POSTGRES_PASSWORD=$pg" `
        "--from-literal=DATABASE_URL=postgres://petpaws:$pg@postgres:5432/petpaws" `
        "--from-literal=JWT_ACCESS_SECRET=$(New-Secret)" `
        "--from-literal=JWT_REFRESH_SECRET=$(New-Secret)" `
        "--from-literal=S3_SECRET_ACCESS_KEY=$(New-Secret)"
} else {
    Write-Host 'already exists'
}

Step 'Bootstrap image (what both colors run before the first pipeline deploy)'
Run docker build -t localhost:5001/taskflow-api:bootstrap backend/api
Run docker push localhost:5001/taskflow-api:bootstrap

Step 'Mirroring MinIO into the local registry (quay.io returns 401 to pulls from inside kind)'
Run docker pull quay.io/minio/minio:latest
Run docker tag quay.io/minio/minio:latest localhost:5001/minio:lab
Run docker push localhost:5001/minio:lab

Step 'Applying Postgres, MinIO and the blue/green Deployments + Services'
Run kubectl apply -f k8s/deps.yaml -f k8s/taskflow.yaml
Run kubectl rollout status deployment/postgres --timeout=180s
Run kubectl rollout status deployment/minio --timeout=180s
Run kubectl rollout status deployment/taskflow-blue --timeout=180s
Run kubectl rollout status deployment/taskflow-green --timeout=180s

Step 'Kubeconfig for Jenkins (internal address, reachable from the "kind" Docker network)'
kind get kubeconfig --name $Cluster --internal | Out-File -Encoding ascii kind-kubeconfig.yaml
if ($LASTEXITCODE -ne 0) { throw 'Could not export kubeconfig' }

Step 'Done'
kubectl get nodes, deploy, svc, pods
Write-Host "`nNext:" -ForegroundColor Green
Write-Host '  1. Jenkins > Credentials > Add > Secret file, ID kind-kubeconfig, upload kind-kubeconfig.yaml'
Write-Host '  2. Then delete it:  Remove-Item kind-kubeconfig.yaml   (it grants admin access to the cluster)'
