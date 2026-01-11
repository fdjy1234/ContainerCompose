param(
  [Parameter(Mandatory = $true)][string]$Prefix,
  [Parameter(Mandatory = $true)][string]$NotifyEmail,
  [Parameter(Mandatory = $false)][int]$BudgetTwd = 500,
  [Parameter(Mandatory = $false)][string]$Location = "eastasia"
)

$ErrorActionPreference = "Stop"

$rg = "rg-$Prefix"
$actionGroupName = "ag-budget-$Prefix".ToLower()
$shortName = ("bud" + $Prefix).Substring(0, [Math]::Min(12, ("bud" + $Prefix).Length)).ToLower()
$receiverName = "notify"
$budgetName = "budget-$Prefix".ToLower()

$az = Get-Command az -ErrorAction SilentlyContinue
if (-not $az) {
  throw "Azure CLI (az) not found. Install it first (see azure/managed/README.md), then re-open the terminal."
}

$null = az account show 2>$null
if ($LASTEXITCODE -ne 0) { throw "Azure CLI not logged in. Run: az login" }

Write-Host "Creating/Updating Action Group for email alerts: $actionGroupName" -ForegroundColor Cyan
$emailArg = "name=$receiverName email=$NotifyEmail"
$azArgs = @('monitor','action-group','create','--resource-group',$rg,'--name',$actionGroupName,'--short-name',$shortName,'--email-receiver',$emailArg)
& az @azArgs | Out-Host

Write-Host "Creating monthly budget (soft cap): NT`$$BudgetTwd ($budgetName)" -ForegroundColor Cyan
Write-Host "Note: Budgets send alerts; they do not automatically stop resources unless you wire automation." -ForegroundColor Yellow

# Budget scope varies by account type. If this command fails, create the budget in the Portal:
# Cost Management -> Budgets -> Create (Amount NT$500, Monthly, Alerts 50/80/100%).
$today = (Get-Date).ToString('yyyy-MM-dd')

$notifObj = @{ 
  actual50 = @{ enabled = $true; operator = 'GreaterThan'; threshold = 50; contactEmails = @($NotifyEmail) }
  actual80 = @{ enabled = $true; operator = 'GreaterThan'; threshold = 80; contactEmails = @($NotifyEmail) }
  actual100 = @{ enabled = $true; operator = 'GreaterThan'; threshold = 100; contactEmails = @($NotifyEmail) }
}

$notifications = $notifObj | ConvertTo-Json -Compress

# az consumption budget create requires budget-name, category and an end date
$endDate = (Get-Date).AddYears(1).ToString('yyyy-MM-dd')
& az consumption budget create --budget-name $budgetName --category cost --amount $BudgetTwd --time-grain Monthly --start-date $today --end-date $endDate --notifications $notifications | Out-Host

Write-Host "Done. If you ever want a hard stop, run cleanup.ps1 to delete rg-$Prefix." -ForegroundColor Green
