param (
    [Parameter(Mandatory)]
    [String]$sub,

    [Parameter(Mandatory)]
    [String]$devopsProjectName
)

$billingAccounts = 'xxxx-8228-43a1-acf8-32cb5b4c5d92:b5b6fef4-e666-4fd2-b303-xxxx'
$billingProfile = 'xxx-U5HS-BG7-xxx'
$invoiceSections = 'xxx-QLVW-PJA-xxx'
$billingScope = "/providers/Microsoft.Billing/billingAccounts/$billingAccounts/billingProfiles/$billingProfile/invoiceSections/$invoiceSections"
$rbac = "Owner"
$devopsOrg = "https://dev.azure.com/xxx"
$devopsOrgName = "xxxx"
$projectId = az devops project show --project $devopsProjectName --query "id" --output tsv
$tenantID = az account show --query "tenantId" -o tsv
$issuer = "https://vstoken.dev.azure.com/xxxx-823d-4a0d-9191-xxx"
$token = az account get-access-token --query accessToken --output tsv

#Create subscriptions
if ($sub -match "-prod-") {
    az account alias create --name $sub --billing-scope $billingScope --display-name $sub --workload 'Production' -o table
}
else {
    az account alias create --name $sub --billing-scope $billingScope --display-name $sub --workload 'DevTest' -o table
}

$spiname = ($sub).Replace('sub', 'sp')

# Create Service Principal
az ad sp create-for-rbac -n $spiname --query "id" -o tsv

# Query the Application ID of the Service Principal and Store it in a variable:-
$spiID = az ad sp list --display-name $spiname --query [].appId -o tsv
    
# Assign the Service Principal, "Contributor" RBAC on Subscription Level:-
$newSub = az account alias show --name $sub --query "properties.subscriptionId" -o tsv
az role assignment create --assignee "$spiID" --role "$rbac" --scope "/subscriptions/$newSub" -o table
    
#Set Service Principal Secret as an Environment Variable for creating Azure DevOps Service Connection:-
#$env:AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY = $spipasswd

# Set Default DevOps Organisation and Project:-
az devops configure --defaults organization=$devopsOrg project=$devopsProjectName -o table

# Create DevOps Service Connection:-
#az devops service-endpoint azurerm create --azure-rm-service-principal-id $spiID --azure-rm-subscription-id $newSub --azure-rm-subscription-name $sub --azure-rm-tenant-id $tenantID --name $spiname --org $devopsOrg --project $devopsProjectName -o table

#Add subscriptions to management group
az account management-group subscription add --name "mg-landingzones-01" --subscription $newSub -o table
az account management-group subscription show-sub-under-mg --name "mg-landingzones-01" --query "[?displayName=='$sub'].{subName: displayName, mgName:'mg-landingzones-01'}" -o table 

#Add Federated credentials
$appId = az ad app list --query "[?displayName=='$spiname'].id" --all -o tsv

$app = az ad app federated-credential list --id $appId --query "[?name=='devops'].id" -o tsv

if ($app) {
    Write-Output "Federated credentials exist"
}
else {
    az ad app federated-credential create --id $appId --parameters `
        "{\""name\"": \""devops\"", \""issuer\"": \""$issuer\"", \""subject\"": \""sc://$devopsOrgName/$devopsProjectName/$spiname\"", \""audiences\"": [\""api://AzureADTokenExchange\""]}" -o table
}

# Create DevOps Service Connection with Federated Credentials:-
$serviceEndpointId = az devops service-endpoint list --query "[?name=='$spiname'].id" -o tsv
$authorization = az devops service-endpoint list --query "[?name=='$spiname'].authorization.scheme" -o tsv
if ($serviceEndpointId) {
    Write-Output "Found service endpoint: $serviceEndpointId"
    if ($authorization -notmatch "WorkloadIdentityFederation") {
        Write-Output "Configuring Workload Identity Federation"
        $uri = "https://dev.azure.com/$devopsOrgName/$devopsProjectName/_apis/serviceendpoint/endpoints/${serviceEndpointId}?operation=ConvertAuthenticationScheme&api-version=7.2-preview.4"
        $body = ConvertTo-Json -Depth 10 @{
            type                             = "azurerm"
            authorization                    = @{
                scheme = "WorkloadIdentityFederation"
            }
            serviceEndpointProjectReferences = @(
                @{
                    description      = ""
                    name             = $spiname
                    projectReference = @{
                        id   = $projectId
                        name = $devopsProjectName
                    }
                }
            )
        }
        Invoke-RestMethod  -Method PUT -Uri $uri  -Headers @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" } -Body $body
    }
}
else {
    Write-Output "Creating service endpoint"
    $uri = "https://dev.azure.com/$devopsOrgName/$devopsProjectName/_apis/serviceendpoint/endpoints?api-version=7.1-preview.4"
    $body = ConvertTo-Json -Depth 10 @{
        type                             = "azurerm"
        name                             = $spiname
        authorization                    = @{
            scheme     = "WorkloadIdentityFederation"
            parameters = @{
                tenantid           = $tenantID
                serviceprincipalid = $spiID
            }
        }
        data                             = @{
            subscriptionId   = $newSub
            subscriptionName = $sub
            environment      = "AzureCloud"
            scopeLevel       = "Subscription"
        }
        serviceEndpointProjectReferences = @(
            @{
                description      = ""
                name             = $spiname
                projectReference = @{
                    id   = $projectId
                    name = $devopsProjectName
                }
            }
        )
    }
    
    Invoke-RestMethod  -Method POST -Uri $uri -Headers @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" } -Body $body
}
