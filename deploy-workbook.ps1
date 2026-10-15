# Deploy the Logic Apps CPU Troubleshooting Workbook via ARM template
# Usage:
#   .\deploy-workbook.ps1 -ResourceGroup "my-test-rg" [-SubscriptionId "xxxx-xxxx"] [-DisplayName "Custom Name"]
#
# Prereqs: az login already run, and the target resource group already exists.

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup,

    [string]$SubscriptionId,

    [string]$DisplayName = "Logic Apps Standard - CPU & Capacity Troubleshooting"
)

$templateFile = Join-Path $PSScriptRoot "LogicApps-CPU-Troubleshooting-Workbook.arm.json"

if ($SubscriptionId) {
    az account set --subscription $SubscriptionId
}

az deployment group create `
    --resource-group $ResourceGroup `
    --template-file $templateFile `
    --parameters workbookDisplayName="$DisplayName" `
    --name "logicapps-cpu-workbook-deploy"

Write-Host "Deployed. Find it under Monitor > Workbooks > '$DisplayName' (or Workbooks tab on the resource group)." -ForegroundColor Green
