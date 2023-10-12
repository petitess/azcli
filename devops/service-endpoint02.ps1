$tenantID = az account show --query "tenantId" -o tsv
$devopsProjectName = "Infrastruktur"
$devopsOrg = "https://dev.azure.com/xxx"
$spiname = "sp-infra-labb-01"
$spiID = "xxx-d622-4abd-8609-xxx"
$newSub = "xxxx-60e3-4a3c-b73b-xxxx"
$sub = "sub-infra-labb-01"
$env:AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY = "p@ssWord01"

$endpointId = az devops service-endpoint list --org $devopsOrg --project $devopsProjectName --query "[?name=='$spiname'].id" -o tsv 

if ($endpointId) {
    Write-Output "Found: $endpointId"
    Write-Output "Deleting: $endpointId"
    az devops service-endpoint delete --id $endpointId --yes
    Start-Sleep -Seconds 10
    Write-Output "Creating service connection"
    az devops service-endpoint azurerm create --azure-rm-service-principal-id $spiID --azure-rm-subscription-id $newSub --azure-rm-subscription-name $sub --azure-rm-tenant-id $tenantID --name $spiname --org $devopsOrg --project $devopsProjectName
}else{
    Write-Output "Not Found. Creating service connection"
    az devops service-endpoint azurerm create --azure-rm-service-principal-id $spiID --azure-rm-subscription-id $newSub --azure-rm-subscription-name $sub --azure-rm-tenant-id $tenantID --name $spiname --org $devopsOrg --project $devopsProjectName
}
