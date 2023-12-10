Set-Location $PSScriptRoot

$Timestamp = Get-Date -Format "dd-MMMM-yyyy HH:mm"
$SubId = "2d9f44ea-e3df-4ea1-b956-8c7a43b119a0"
$Rg = 'rg-aa-prod-01'
$Aa = "aa-prod-01"

$Runbooks = Get-ChildItem ..\ -Filter "run-*"

$Runbooks | ForEach-Object {
    az automation runbook create `
        --automation-account-name $Aa `
        --name $_.Name `
        --resource-group $Rg `
        --description "Updated $Timestamp" `
        --type 'PowerShell'

    az automation runbook replace-content `
        --automation-account-name $Aa `
        --name $_.Name `
        --content "@$($_)" `
        --resource-group $Rg `
        --subscription $SubId

    az automation runbook publish `
        --automation-account-name $Aa `
        --name $_.Name `
        --resource-group $Rg `
        --subscription $SubId
}
