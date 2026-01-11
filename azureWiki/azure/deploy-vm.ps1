param(
  [Parameter(Mandatory = $true)][string]$ResourceGroup,
  [Parameter(Mandatory = $true)][string]$VmName,
  [Parameter(Mandatory = $true)][string]$PublicHost,
  [Parameter(Mandatory = $false)][string]$SshUser = "azureuser",
  [Parameter(Mandatory = $false)][string]$ProjectLocalPath = (Resolve-Path "..\").Path
)

$remotePath = "/opt/wikijs"

Write-Host "Uploading compose bundle to $SshUser@$PublicHost:$remotePath" -ForegroundColor Cyan

# Requires OpenSSH client (Windows 10/11 usually has it).
scp -r "$ProjectLocalPath\*" "$SshUser@$PublicHost`:$remotePath/" | Out-Host

Write-Host "Starting containers" -ForegroundColor Cyan
ssh "$SshUser@$PublicHost" "cd $remotePath; cp -n .env.example .env; docker compose up -d" | Out-Host

Write-Host "Done. Next: edit /opt/wikijs/.env on the VM (DOMAIN/ADMIN_EMAIL/POSTGRES_PASSWORD) then: docker compose --profile proxy up -d" -ForegroundColor Green
