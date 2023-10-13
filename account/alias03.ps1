param (
    [Parameter(Mandatory)]
    [String]$sub,

    [Parameter(Mandatory)]
    [String]$devopsProjectName
)

$billingAccounts = 'xxxxxx-8228-43a1-acf8-32cb5b4c5d92:b5b6fef4-e666-4fd2-b303-xxxxxx_2019-05-31'
$billingProfile = 'xxxx-U5HS-BG7-xxx'
$invoiceSections = 'xx-QLVW-PJA-xxx'
$billingScope = "/providers/Microsoft.Billing/billingAccounts/$billingAccounts/billingProfiles/$billingProfile/invoiceSections/$invoiceSections"
$rbac = "Owner"
$devopsOrg = "https://dev.azure.com/xxxse"
$devopsOrgName = "xxxse"
$tenantID = az account show --query "tenantId" -o tsv
$issuer = "https://vstoken.dev.azure.com/xxxxx-823d-4a0d-9191-xxxx"

#Create subscriptions
if ($sub -match "-prod-") {
    az account alias create --name $sub --billing-scope $billingScope --display-name $sub --workload 'Production' 
}
else {
    az account alias create --name $sub --billing-scope $billingScope --display-name $sub --workload 'DevTest'
}

$spiname = ($sub).Replace('sub', 'sp')

# Create Service Principal
$spipasswd = az ad sp create-for-rbac -n $spiname --query "password" -o tsv

# Query the Application ID of the Service Principal and Store it in a variable:-
$spiID = az ad sp list --display-name $spiname --query [].appId -o tsv
    
# Assign the Service Principal, "Contributor" RBAC on Subscription Level:-
$newSub = az account alias show --name $sub --query "properties.subscriptionId" -o tsv
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
az account management-group subscription add --name "mg-landingzones-01" --subscription $newSub

#Add Federated credentials
$appId = az ad app list --query "[?displayName=='$spiname'].id" --all -o tsv

$app = az ad app federated-credential list --id $appId --query "[?name=='devops'].id" -o tsv

if ($app) {
    Write-Output "Federated credentials exist"
}
else {
    az ad app federated-credential create --id $appId --parameters `
        "{\""name\"": \""devops\"", \""issuer\"": \""$issuer\"", \""subject\"": \""sc://$devopsOrgName/$devopsProjectName/$spiname\"", \""audiences\"": [\""api://AzureADTokenExchange\""]}"
}
