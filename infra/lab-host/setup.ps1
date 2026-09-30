# Lab 08: (re)create the Ansible target host on the lab08 network.
# Run from the repo root:  powershell -ExecutionPolicy Bypass -File infra\lab-host\setup.ps1
# Needs lab08_key.pub in the repo root (the public half of the lab08-ssh-key credential).
# The Docker socket is mounted so `docker pull` on this host uses the local daemon, which can
# reach the Lab 07 registry at localhost:5001.
$ErrorActionPreference = 'Stop'
docker build -t lab08-host infra/lab-host
if ($LASTEXITCODE -ne 0) { throw 'image build failed' }
docker rm -f taskflow-vm 2>$null | Out-Null
docker run -d --name taskflow-vm --hostname taskflow-vm --restart unless-stopped --network lab08 `
    -v //var/run/docker.sock:/var/run/docker.sock lab08-host | Out-Null
Get-Content lab08_key.pub | docker exec -i taskflow-vm sh -c 'cat > /home/ubuntu/.ssh/authorized_keys && chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys && chmod 600 /home/ubuntu/.ssh/authorized_keys'
Write-Host 'taskflow-vm is up on the lab08 network (ssh ubuntu@taskflow-vm)'
