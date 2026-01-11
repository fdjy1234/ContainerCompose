# Azure CLI commands (VM + Docker)

These commands create a low-cost Ubuntu VM, install Docker via cloud-init, and open ports 80/443.

## Variables

PowerShell example:

```powershell
$location = "eastasia"            # pick your region
$resourceGroup = "rg-wikijs"      # any name
$vmName = "vm-wikijs"
$dnsLabel = "mywikijs-12345"      # must be globally unique in the region
$adminUsername = "azureuser"
$cloudInitPath = "./azure/cloud-init.yaml"
```

## Create resource group

```powershell
az group create --name $resourceGroup --location $location
```

## Create VM (SSH keys + cloud-init)

If you already have SSH keys, you can add `--ssh-key-values`.

```powershell
az vm create `
  --resource-group $resourceGroup `
  --name $vmName `
  --image Canonical:UbuntuServer:22_04-lts:latest `
  --custom-data $cloudInitPath `
  --admin-username $adminUsername `
  --generate-ssh-keys `
  --size Standard_B1ms `
  --public-ip-address-dns-name $dnsLabel
```

## Open ports 80/443

```powershell
az vm open-port --resource-group $resourceGroup --name $vmName --port 80
az vm open-port --resource-group $resourceGroup --name $vmName --port 443
```

## Get public FQDN + IP

```powershell
az vm show --resource-group $resourceGroup --name $vmName --query "{FQDN:Fqdn,IP:PublicIpAddress}" --output table
```

## Next

- Upload this project to `/opt/wikijs` on the VM
- Set `/opt/wikijs/.env` (DOMAIN/ADMIN_EMAIL/POSTGRES_PASSWORD)
- Run: `docker compose up -d`
