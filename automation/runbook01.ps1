Set-Location $PSScriptRoot

$Date = Get-Date -Format "yyyy-MM-dd"
$Temp = (Get-date).AddDays(1)
$Tomorrow = Get-Date $Temp -Format "yyyy-MM-dd"
$SubId = "xxx-e3df-4ea1-b956-8c7a43b119a0"
$Rg = 'rg-aa-prod-01'
$Aa = "aa-prod-01"

$Runbooks = Get-ChildItem ..\ -Filter "run-*"

$Runbooks | ForEach-Object {
    az automation runbook create `
        --automation-account-name $Aa `
        --name $_.Name `
        --resource-group $Rg `
        --description "Updated $(Get-Date)" `
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

az automation schedule create `
    --automation-account-name $Aa `
    --frequency "Day" `
    --interval 1 `
    --start-time (((Get-Date) -gt ($Date+" 20:50")) ? ($Tomorrow +" 21:00") : ($Date+" 21:00")) `
    --name "sch-01" `
    --resource-group $Rg `
    --time-zone "Europe/Stockholm"
