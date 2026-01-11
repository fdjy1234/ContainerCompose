param(
  [Parameter(Mandatory = $true)][string]$Prefix,
  [Parameter(Mandatory = $true)][string]$NotifyEmail,
  [Parameter(Mandatory = $false)][string]$Location = "eastasia",
  [Parameter(Mandatory = $false)][int]$BudgetTwd = 500
)

$ErrorActionPreference = "Stop"

# Names
$rg = "rg-$Prefix"
$pgServer = "pg-$Prefix".ToLower()
$pgDb = "wikijs"
$caEnv = "cae-$Prefix".ToLower()
$caApp = "ca-$Prefix".ToLower()
$actionGroup = "ag-budget-$Prefix".ToLower()
$budgetName = "budget-$Prefix".ToLower()

function Require-Az {
  $az = Get-Command az -ErrorAction SilentlyContinue
  if (-not $az) {
    throw "Azure CLI (az) not found. Install it first (see azure/managed/README.md), then re-open the terminal." 
  }
  $null = az account show 2>$null
  if ($LASTEXITCODE -ne 0) {
    throw "Azure CLI not logged in. Run: az login"
  }
}

function New-RandomPassword {
  param([int]$Length = 24)
  # avoid quotes/backslashes for easier CLI passing
  $chars = (48..57 + 65..90 + 97..122) | ForEach-Object { [char]$_ }
  -join (1..$Length | ForEach-Object { $chars | Get-Random })
}

Require-Az

Write-Host "Creating resource group: $rg ($Location)" -ForegroundColor Cyan
az group create --name $rg --location $Location | Out-Host

# Generate DB admin password
$pgAdminUser = "wikijsadmin"
$pgAdminPass = New-RandomPassword

Write-Host "Creating PostgreSQL Flexible Server: $pgServer" -ForegroundColor Cyan
# Burstable B1ms: lowest common cost tier for Flexible Server.
# Public access is enabled for fast trial (not recommended long-term).
az postgres flexible-server create `
  --resource-group $rg `
  --location $Location `
  --name $pgServer `
  --admin-user $pgAdminUser `
  --admin-password $pgAdminPass `
  --tier Burstable `
  --sku-name Standard_B1ms `
  --storage-size 32 `
  --version 16 `
  --backup-retention 7 `
  --yes | Out-Host

Write-Host "Creating firewall rule for quick trial access (wide open): AllowContainerApps" -ForegroundColor Yellow
az postgres flexible-server firewall-rule create `
  --resource-group $rg `
  --name $pgServer `
  --rule-name AllowContainerApps `
  --start-ip-address 0.0.0.0 `
  --end-ip-address 255.255.255.255 | Out-Host

Write-Host "Ensuring database exists: $pgDb" -ForegroundColor Cyan
az postgres flexible-server db create --resource-group $rg --server-name $pgServer --database-name $pgDb | Out-Host

Write-Host "Creating Container Apps environment (logs disabled to reduce cost): $caEnv" -ForegroundColor Cyan
az containerapp env create --name $caEnv --resource-group $rg --location $Location --logs-destination none | Out-Host

Write-Host "Creating Container App: $caApp" -ForegroundColor Cyan
az containerapp create `
  --name $caApp `
  --resource-group $rg `
  --environment $caEnv `
  --image "ghcr.io/requarks/wiki:2" `
  --ingress external `
  --target-port 3000 `
  --cpu 0.25 `
  --memory 0.5Gi `
  --max-replicas 1 `
  --secrets "dbpass=$pgAdminPass" `
  --env-vars `
    "DB_TYPE=postgres" `
    "DB_HOST=$pgServer.postgres.database.azure.com" `
    "DB_PORT=5432" `
    "DB_USER=$pgAdminUser" `
    "DB_PASS=secretref:dbpass" `
    "DB_NAME=$pgDb" `
    "DB_SSL=true" `
    "DB_SSL_REJECT_UNAUTHORIZED=false" `
    "NODE_ENV=production" `
  | Out-Host

# Output URL
$fqdn = az containerapp show --name $caApp --resource-group $rg --query "properties.configuration.ingress.fqdn" -o tsv
Write-Host "Wiki.js URL: https://$fqdn" -ForegroundColor Green

Write-Host "Next (cost cap): run set-budget.ps1 to create the NT$$BudgetTwd/month budget alerts." -ForegroundColor Yellow
Write-Host "Budget: .\\azure\\managed\\set-budget.ps1 -Prefix $Prefix -NotifyEmail $NotifyEmail -BudgetTwd $BudgetTwd -Location $Location" -ForegroundColor Yellow
Write-Host "Cleanup (hard stop): .\\azure\\managed\\cleanup.ps1 -ResourceGroup $rg" -ForegroundColor Yellow

# Print DB creds once (user should store securely)
Write-Host "PostgreSQL admin user: $pgAdminUser" -ForegroundColor Yellow
Write-Host "PostgreSQL admin password: $pgAdminPass" -ForegroundColor Yellow
Write-Host "PostgreSQL host: $pgServer.postgres.database.azure.com" -ForegroundColor Yellow
