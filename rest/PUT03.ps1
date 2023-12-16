$SubId = "2d9f44ea-e3df-4ea1-b956-8c7a43b119a0"
$Rg = 'rg-aa-prod-01'
$Aa = "aa-prod-01" 
$body = ConvertTo-Json -Depth 100  @{
    properties = @{
        schedule = @{
            name = "sch-01"
        }
        runbook = @{
            name = "run-removeResourceGroups01"
        }
    }
}
$formatedBody = ($body -split "`r`n`r`n").replace("`r`n", "" )
az rest --uri "https://management.azure.com/subscriptions/$subId/resourcegroups/$Rg/providers/Microsoft.Automation/automationAccounts/$Aa/jobSchedules/$((New-Guid).Guid)?api-version=2023-11-01" --method put --body ($formatedBody | ConvertTo-Json -Compress )

