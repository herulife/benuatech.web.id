param(
  [string]$Host = "103.107.206.10",
  [int]$Port = 2480,
  [string]$User = "ubuntu24",
  [string]$RepoDir = "/home/ubuntu24/my-docker-apps/apps/benuatech.web.id",
  [string]$StackDir = "/home/ubuntu24/my-docker-apps"
)

$commands = @(
  "cd $RepoDir",
  "git fetch origin",
  "git reset --hard origin/main",
  "npm ci",
  "npm run build",
  "cd $StackDir",
  "docker compose up -d --no-deps --force-recreate nginx"
)

$remoteCommand = ($commands -join " && ")

Write-Host "Deploying BenuaTech from origin/main to VPS $Host..."
ssh -p $Port "$User@$Host" $remoteCommand
