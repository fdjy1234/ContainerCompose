# 全代管試用（Azure Container Apps + PostgreSQL Flexible Server）

目標：在 `eastasia` 快速建立一套可用的 Wiki.js，並設定 **每月 NT$500 的預算警示**，降低試用期間超支風險。

> 重要：Azure Budget 是「警示/觸發」，不是 100% 硬切斷。要做到接近硬上限，建議用警示 + 立刻執行清除（或另外接自動化刪除資源）。

## 你會得到什麼

- Wiki.js 以 Azure Container Apps（Consumption）執行，外網 HTTPS + FQDN
- PostgreSQL 使用 Azure Database for PostgreSQL Flexible Server（Burstable B1ms）
- Azure Budget（每月 NT$500）在 50% / 80% / 100% 通知
- 一鍵清除資源（刪除整個 Resource Group）

## 前置需求

- 安裝 Azure CLI 並登入：`az login`
	- 推薦用 WinGet：`winget install -e --id Microsoft.AzureCLI`
	- 若已安裝但終端機找不到 `az`，可重開終端機，或更新 PATH：
		- `$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")`
- 具備建立資源權限（Resource Group、Container Apps、PostgreSQL、Budgets、Action Group）

## 1) 部署（建立資源）

在 repo 根目錄執行：

```powershell
Set-Location C:\Users\fdjy1\azureWiki

# 第一次先改參數：prefix / admin email / budget email
.\azure\managed\deploy-managed.ps1 -Prefix "mywiki" -NotifyEmail "you@example.com"
```

部署完成後腳本會輸出 Wiki.js 的 URL（FQDN）。

## 2) 成本控制（Budget）

執行：

```powershell
.\azure\managed\set-budget.ps1 -Prefix "mywiki" -NotifyEmail "you@example.com" -BudgetTwd 500
```

它會建立：

- Action Group（寄信到你指定的 Email）
- Budget：NT$500/月，50/80/100% 通知（soft cap）

你也可以到 Azure Portal → Cost Management → Budgets 看到它。

## 3) 停用/清除（避免持續計費）

如果你不玩了，建議直接刪掉整個 RG（最乾淨、最接近硬上限）：

```powershell
.\azure\managed\cleanup.ps1 -ResourceGroup "rg-mywiki"
```

## 4) 注意事項（重要）

- **PostgreSQL Flexible Server 就算閒置仍會計算力費用**（除非你手動 Stop / Start）。
- Container Apps Consumption 若你設定 scale-to-zero 且沒流量，費用通常很低；但**資料庫仍是主要固定成本**。
- 為了「快速試用」，此版本使用 **public access** 連線到 PostgreSQL（不做私網整合）。長期使用時建議改成 Private networking。
