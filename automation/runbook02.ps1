Set-Location $PSScriptRoot

$Date = Get-Date -Format "yyyy-MM-dd"
$Temp = (Get-date).AddDays(1)
$Tomorrow = Get-Date $Temp -Format "yyyy-MM-dd"
$SubId = "2d9f44ea-e3df-4ea1-b956-8c7a43b119a0"
$Rg = 'rg-aa-prod-01'
$Aa = "aa-prod-01"

$Runbooks = Get-ChildItem ..\ -Filter "run-*"
#Create runbooks
$Runbooks | ForEach-Object {
    az automation runbook create `
        --automation-account-name $Aa `
        --name $_.Name.Replace(".ps1", "") `
        --resource-group $Rg `
        --description "Updated $(Get-Date)" `
        --type 'PowerShell'

    az automation runbook replace-content `
        --automation-account-name $Aa `
        --name $_.Name.Replace(".ps1", "") `
        --content "@$($_)" `
        --resource-group $Rg `
        --subscription $SubId

    az automation runbook publish `
        --automation-account-name $Aa `
        --name $_.Name.Replace(".ps1", "") `
        --resource-group $Rg `
        --subscription $SubId
}
#Create schedules
$schedulesEveryDay = @(20,21,22)
$schedulesEveryDay | ForEach-Object {
az automation schedule create `
    --automation-account-name $Aa `
    --frequency "Day" `
    --interval 1 `
    --start-time (((Get-Date) -gt ($Date+ " " + ($_-1) +":50")) ? ($Tomorrow + " " + $_ +":00") : ($Date+ " " + $_ +":00")) `
    --name "sch-$_-daily" `
    --resource-group $Rg `
    --time-zone "Europe/Stockholm"
}
#Link schedules
$LinkSchedule = @(
    [pscustomobject]@{runbookName = 'run-removeResourceGroups01'; scheduleName = 'sch-21-daily' }
    [pscustomobject]@{runbookName = 'run-removeResourceGroups01'; scheduleName = 'sch-22-daily' }
)

$LinkSchedule | ForEach-Object {
$body = ConvertTo-Json -Depth 100  @{
    properties = @{
        schedule = @{
            name = $_.scheduleName
        }
        runbook = @{
            name = $_.runbookName
        }
    }
}
$formatedBody = ($body -split "`r`n`r`n").replace("`r`n", "" )
az rest --uri "https://management.azure.com/subscriptions/$subId/resourcegroups/$Rg/providers/Microsoft.Automation/automationAccounts/$Aa/jobSchedules/$((New-Guid).Guid)?api-version=2023-11-01" --method put --body ($formatedBody | ConvertTo-Json -Compress )
}
