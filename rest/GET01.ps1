$subName = "sub-infra-prod-01"
$subId = az account list --query "[?name=='$subName'].id" -o tsv
$rgName = "rg-infra-spoke-prod-we-01"

az rest --uri "https://management.azure.com/subscriptions/$subId/resourcegroups/${rgName}?api-version=2021-04-01"
