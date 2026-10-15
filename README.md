# Logic Apps Standard — Troubleshooting Dashboard

An Azure Monitor Workbook for diagnosing issues on **Logic Apps Standard** (WS-1/WS-2/WS-3 App Service Plans) — covering workflow run failures, CPU/capacity symptoms (e.g. sustained near-100% CPU with no actively running workflows), and the storage/Cosmos DB dependencies that often cause them.

**Fully customer-agnostic** — no hardcoded subscription, resource group, or resource names. Every target (Subscription, App Service Plan, Logic App, Storage Account, Cosmos DB account, Log Analytics Workspace) is picked from a live dropdown at open time.

## What it covers

1. **Workflow Run History & Errors** — failed/timed-out/aborted runs and their error messages, pulled from Log Analytics (requires Diagnostic Settings — see item 6 below)
2. **App Service Plan** — CPU %, Memory %, HTTP Queue Length
3. **Logic App / Function host** — execution count/units, 5xx errors, response time (catches stuck/looping triggers even on workflows marked "disabled")
4. **Backing Storage Account** — transactions, E2E latency (storage throttling is a common silent cause of CPU spin)
5. **Cosmos DB backend** — normalized RU consumption, total RUs (RU-throttling retry storms)
6. **Recommended alert rules** — a ready-to-configure table, plus an explicit call-out: historical platform metrics go back 93 days automatically, but detailed diagnostic logs (including everything Section 1 depends on) only exist from when Diagnostic Settings are enabled — turn that on today if it isn't already.

## Deploy

### Option 1 — One-click (recommended for customers)

[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FTrevor-Davis%2Flogicapps-standard-troubleshooting-workbook%2Fmaster%2Fazuredeploy.json)

Click the button, pick your Subscription + Resource Group, and deploy. The workbook will appear under **Monitor → Workbooks** in that resource group.

### Option 2 — Azure CLI

```powershell
git clone https://github.com/Trevor-Davis/logicapps-standard-troubleshooting-workbook.git
cd logicapps-standard-troubleshooting-workbook

az login
az group create --name "your-rg" --location "eastus"   # skip if the RG already exists

.\deploy-workbook.ps1 -ResourceGroup "your-rg"
```

### Option 3 — Manual import (no CLI needed)

1. Download [`workbook.json`](./workbook.json) from this repo (or copy its raw contents)
2. Azure Portal → **Monitor → Workbooks → New → Advanced Editor** (`</>` icon)
3. Paste the JSON → **Apply** → **Done Editing** → **Save**

## After deploying

Open the workbook and select, from the dropdowns at the top:
- **Subscription**
- **App Service Plan** (your WS-1/WS-2/WS-3 plan)
- **Logic App / Function App**
- **Storage Account** (the one backing the Logic App)
- **Cosmos DB account** (optional, if your workflows use Cosmos DB)
- **Log Analytics Workspace** (optional, needed for the Workflow Run History & Errors section)

All panels update automatically based on your selections — no editing required.

## Workflow Run History caveat

Section 1's query searches both `AzureDiagnostics` (classic export) and `LogicAppWorkflowRuntime` (resource-specific export) since the exact table/column schema depends on how your Diagnostic Settings are configured. It's a starting query, not a guaranteed-exact one — if it returns no rows, check the **Logs** blade directly to confirm which table your logs are landing in and adjust the query if needed.

## Historical data

- **Platform metrics** (CPU%, Memory%, Queue Length, Function executions, Storage/Cosmos metrics) are collected by Azure automatically for every resource, retained **93 days**, and work retroactively — even for dates before you deployed this workbook.
- **Diagnostic/trigger-level logs and Application Insights telemetry** only start accumulating from the moment Diagnostic Settings / App Insights are enabled on the resource. If not already on, enable it now — there is no backfill.

## Files

| File | Purpose |
|---|---|
| `workbook.json` | Raw workbook definition — for manual import via Advanced Editor |
| `azuredeploy.json` | ARM template that deploys the workbook as a resource — used by the Deploy to Azure button and CLI |
| `deploy-workbook.ps1` | PowerShell helper wrapping `az deployment group create` |

## License

Internal/customer reference tooling — no warranty implied. Adjust alert thresholds to your own workload before relying on them in production.
