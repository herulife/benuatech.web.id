param(
  [string]$ServerHost = "103.107.206.10",
  [int]$Port = 2480,
  [string]$User = "ubuntu24",
  [string]$RepoDir = "/home/ubuntu24/my-docker-apps/apps/benuatech.web.id",
  [string]$StackDir = "/home/ubuntu24/my-docker-apps",
  [string]$SudoPassword
)

if (-not $SudoPassword) {
  $securePassword = Read-Host "Sudo password for VPS" -AsSecureString
  $credentialBstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
  try {
    $SudoPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($credentialBstr)
  }
  finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($credentialBstr)
  }
}

$commands = @(
  "git config --global --add safe.directory $RepoDir",
  "cd $RepoDir",
  "git fetch origin",
  "git reset --hard origin/main",
  "npm ci",
  "rm -rf dist",
  "npm run build",
  "cd $StackDir",
  "docker compose up -d --no-deps --force-recreate nginx"
)

$remoteCommand = ($commands -join " && ")
$escapedPassword = $SudoPassword.Replace("'", "'""'""'")
$escapedCommand = $remoteCommand.Replace("'", "'""'""'")
$sshCommand = "printf '%s\n' '$escapedPassword' | sudo -S bash -lc '$escapedCommand'"

Write-Host "Deploying BenuaTech from origin/main to VPS $ServerHost..."
ssh -p $Port "$User@$ServerHost" $sshCommand
