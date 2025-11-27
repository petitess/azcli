param (
    [Parameter(Mandatory)]
    [Alias('DevOps Project Name')]
    [String]$DevopsProjectName,

    [Parameter(Mandatory)]
    [Alias('Service Connection Name')]
    [String]$spName
)
$SubName  = "sub-infra-dev-01"
# $rbac = "Owner"
$devopsOrg = "https://dev.azure.com/abcd"
$devopsOrgName = "ssgse"
$projectId = az devops project show --project $DevopsProjectName --query "id" --output tsv
$tenantID = az account show --query "tenantId" -o tsv
$issuer = "https://vstoken.dev.azure.com/20a69f6e-823d-4a0d-9191-c6832fa0baa0"
$token = az account get-access-token --query accessToken --output tsv

# Create Service Principal
$appId = az ad app create --display-name $spName --query "appId" -o tsv
#pim.karol@abcs.onmicrosoft.com
az ad app owner add --id $appId --owner-object-id "08f93fac-ac50-4ee0-8edb-1ccb4e50530d"
az ad sp create --id $appId
# Assign the Service Principal, "Owner" RBAC on Subscription Level:-
$subId = az account alias show --name $SubName --query "properties.subscriptionId" -o tsv
# az role assignment create --assignee "$appId" --role "$rbac" --scope "/subscriptions/$subId" -o table

# Set Default DevOps Organisation and Project:-
az devops configure --defaults organization=$devopsOrg project=$DevopsProjectName -o table
#OLD
# az ad app federated-credential create --id $appId --parameters `
#     "{\""name\"": \""devops\"", \""issuer\"": \""$issuer\"", \""subject\"": \""sc://$devopsOrgName/$DevopsProjectName/$spName\"", \""audiences\"": [\""api://AzureADTokenExchange\""]}" -o table
#NEW
az ad app federated-credential create --id $appId -o table --parameters @"
    {
        "name": "devops",
        "issuer": "$issuer",
        "subject": "sc://$devopsOrgName/$DevopsProjectName/$spName",
        "audiences": ["api://AzureADTokenExchange"]
    }
"@ 

# Create DevOps Service Connection with Federated Credentials:
Write-Output "Creating service endpoint"
$uri = "https://dev.azure.com/$devopsOrgName/$DevopsProjectName/_apis/serviceendpoint/endpoints?api-version=7.1-preview.4"
$body = ConvertTo-Json -Depth 10 @{
    type                             = "azurerm"
    name                             = $spName
    authorization                    = @{
        scheme     = "WorkloadIdentityFederation"
        parameters = @{
            tenantid           = $tenantID
            serviceprincipalid = $appId #$spiID
        }
    }
    data                             = @{
        subscriptionId   = $subId
        subscriptionName = $SubName
        environment      = "AzureCloud"
        scopeLevel       = "Subscription"
    }
    serviceEndpointProjectReferences = @(
        @{
            name             = $spName
            projectReference = @{
                id   = $projectId
                name = $DevopsProjectName
            }
        }
    )
}
    
Invoke-RestMethod  -Method POST -Uri $uri -Headers @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" } -Body $body

