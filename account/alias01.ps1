param (
    [Parameter(Mandatory)]
    [String]$sub,

    [Parameter(Mandatory)]
    [String]$devopsProjectName
)

$billingAccounts = 'xxxx-8228-43a1-acf8-32cb5b4c5d92:b5b6fef4-e666-4fd2-b303-xxx_2019-05-31'
$billingProfile = 'XXXX-U5HS-BG7-XXX'
$invoiceSections = 'XXXX-QLVW-PJA-XXX'
$billingScope = "/providers/Microsoft.Billing/billingAccounts/$billingAccounts/billingProfiles/$billingProfile/invoiceSections/$invoiceSections"
$rbac = "Owner"
$devopsOrg = "https://dev.azure.com/sxxx"
$tenantID = az account show --query "tenantId" -o tsv

#Create subscriptions
if ($sub -match "-prod-") {
    az account alias create --name $sub --billing-scope $billingScope --display-name $sub --workload 'Production' 
}
else {
    az account alias create --name $sub --billing-scope $billingScope --display-name $sub --workload 'DevTest'
}

$spiname = ($sub).Replace('sub', 'sp')

$appId = az ad app list --query "[?displayName=='$spiname'].id" --all -o tsv

if ($appId) {
    Write-Output "Found: $appId"
}
else {
    Write-Output "Not Found"
    $spipasswd = az ad sp create-for-rbac -n $spiname --query "password" -o tsv
}

# Query the Application ID of the Service Principal and Store it in a variable:-
$spiID = az ad sp list --display-name $spiname --query [].appId -o tsv
    
# Assign the Service Principal, "Contributor" RBAC on Subscription Level:-
az role assignment create --assignee "$spiID" --role "$rbac" --scope "/subscriptions/$newSub"
    
#Set Service Principal Secret as an Environment Variable for creating Azure DevOps Service Connection:-
$env:AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY = $spipasswd

# Set Default DevOps Organisation and Project:-
az devops configure --defaults organization=$devopsOrg project=$devopsProjectName
    
# Create DevOps Service Connection:-
az devops service-endpoint azurerm create --azure-rm-service-principal-id $spiID --azure-rm-subscription-id $newSub --azure-rm-subscription-name $sub --azure-rm-tenant-id $tenantID --name $spiname --org $devopsOrg --project $devopsProjectName
    
# Grant Access to all Pipelines to the Newly Created DevOps Service Connection:-
$srvEndpointID = az devops service-endpoint list --query "[?name=='$spiname'].id" -o tsv
#az devops service-endpoint update --id $srvEndpointID --enable-for-all
$srvEndpointID

#Add subscriptions to management group
$newSub = az account alias show --name $sub --query "properties.subscriptionId" -o tsv
az account management-group subscription add --name "mg-landingzones-01" --subscription $newSub
