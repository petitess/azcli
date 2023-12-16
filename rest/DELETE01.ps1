$SubId = "2d9f44ea-e3df-4ea1-b956-8c7a43b119a0"
$Rg = 'rg-aa-prod-01'
$Aa = "aa-prod-01"
$Url = "https://management.azure.com/subscriptions/$subId/resourcegroups/$Rg/providers/Microsoft.Automation/automationAccounts/$Aa/jobSchedules"

$JobId = az rest --uri "$($Url)?api-version=2023-11-01" `
--method GET `
--query "value[?properties.runbook.name=='run-removeResourceGroups01'].properties.jobScheduleId" -o tsv

$JobId | ForEach-Object {
az rest --uri "$Url/$($_)?api-version=2023-11-01" `
--method DELETE
}
