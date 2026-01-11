param(
  [Parameter(Mandatory = $true)][string]$ResourceGroup
)

$ErrorActionPreference = "Stop"

Write-Host "Deleting resource group: $ResourceGroup" -ForegroundColor Red
Write-Host "This will stop all charges for resources in the RG." -ForegroundColor Red

az group delete --name $ResourceGroup --yes --no-wait | Out-Host
Write-Host "Delete started. You can check in Azure Portal or run: az group exists -n $ResourceGroup" -ForegroundColor Green
