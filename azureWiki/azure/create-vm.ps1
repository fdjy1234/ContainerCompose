param(
  [Parameter(Mandatory = $false)][string]$Location = "eastasia",
  [Parameter(Mandatory = $false)][string]$ResourceGroup = "rg-wikijs",
  [Parameter(Mandatory = $false)][string]$VmName = "vm-wikijs",
  [Parameter(Mandatory = $true)][string]$DnsLabel,
  [Parameter(Mandatory = $false)][string]$AdminUsername = "azureuser",
  [Parameter(Mandatory = $false)][string]$VmSize = "Standard_B1ms",
  [Parameter(Mandatory = $false)][string]$CloudInitPath = "./azure/cloud-init.yaml"
)

$ErrorActionPreference = "Stop"

Write-Host "Creating resource group..." -ForegroundColor Cyan
az group create --name $ResourceGroup --location $Location | Out-Host

Write-Host "Creating VM (Ubuntu 22.04 LTS + cloud-init + SSH keys)..." -ForegroundColor Cyan
az vm create `
  --resource-group $ResourceGroup `
  --name $VmName `
  --image Canonical:UbuntuServer:22_04-lts:latest `
  --custom-data $CloudInitPath `
  --admin-username $AdminUsername `
  --generate-ssh-keys `
  --size $VmSize `
  --public-ip-address-dns-name $DnsLabel | Out-Host

Write-Host "Opening ports 80/443..." -ForegroundColor Cyan
az vm open-port --resource-group $ResourceGroup --name $VmName --port 80 | Out-Host
az vm open-port --resource-group $ResourceGroup --name $VmName --port 443 | Out-Host

Write-Host "Public endpoint:" -ForegroundColor Cyan
az vm show --resource-group $ResourceGroup --name $VmName --query "{FQDN:Fqdn,IP:PublicIpAddress}" --output table | Out-Host

Write-Host "Next: upload files to /opt/wikijs and run docker compose." -ForegroundColor Green
