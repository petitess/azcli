##version 1
$subName = "sub-infra-dev-01"
$subId = az account list --query "[?name=='$subName'].id" -o tsv
$rgName = "rg-xxx-spoke-dev-we-01"
az rest --url "https://management.azure.com/subscriptions/$subId/resourcegroups/${rgName}?api-version=2023-07-01" --method put --body '{\"location\": \"westeurope\"}'

##version 2
$subName = "sub-infra-dev-01"
$subId = az account list --query "[?name=='$subName'].id" -o tsv
$rgName = "rg-xxx-spoke-dev-we-01"
$json = 
@"
{
"location": "westeurope"
}
"@
$formatedJson = ($json -split "`r`n`r`n").replace("`r`n", "" )
az rest --url "https://management.azure.com/subscriptions/$subId/resourcegroups/${rgName}?api-version=2023-07-01" --method put --body ($formatedJson | ConvertTo-Json -Compress )
