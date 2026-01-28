param (
    [Parameter(Mandatory)]
    [Alias('DevOps Project Name')]
    [String]$DevopsProjectName,

    [Parameter(Mandatory)]
    [Alias('Service Connection Name')]
    [String]$spName
)
$SubName = "sub-infra-dev-01"
$rbac = "Owner"
$devopsOrg = "https://dev.azure.com/abcd"
$devopsOrgName = "abcdse"
$projectId = az devops project show --project $DevopsProjectName --org $devopsOrg --query "id" --output tsv
$tenantID = az account show --query "tenantId" -o tsv
$token = az account get-access-token --query accessToken --output tsv

# Create Service Principal
$appId = az ad app create --display-name $spName --query "appId" -o tsv
az ad app owner add --id $appId --owner-object-id "08f93fac-ac50-4ee0-8edb-1ccb4e50530d"
az ad sp create --id $appId
# Assign the Service Principal, "Owner" RBAC on Subscription Level:-
$subId = az account subscription list --query "[?state=='Enabled' && displayName=='$SubName'].subscriptionId" -o tsv
az role assignment create --assignee "$appId" --role "$rbac" --scope "/subscriptions/$subId" -o table

# Set Default DevOps Organisation and Project:-
az devops configure --defaults organization=$devopsOrg project=$DevopsProjectName -o table

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
            serviceprincipalid = $appId
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
    
$NewSe = Invoke-RestMethod  -Method POST -Uri $uri -Headers @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" } -Body $body
$Issuer = $NewSe.authorization.parameters.workloadIdentityFederationIssuer 
$Subject = $NewSe.authorization.parameters.workloadIdentityFederationSubject 

$app = az ad app federated-credential list --id $appId --query "[?name=='devops'].id" -o tsv

if ($app) {
    Write-Output "Federated credentials exist"
}
else {
    $url = "https://graph.microsoft.com/v1.0/applications?`$filter=appId eq '$appId'"
    $headers = "Content-type=application/json"
    $ObjectId = az rest --method get --uri $url --headers $headers --query "value[0].id" -o tsv
    if (!$ObjectId) {
        Write-Error "Failed to retrieve Object ID for appId: $appId."
        exit 1
    }

    $FedParameters = @{
        name      = "devops"
        issuer    = "$Issuer"
        subject   = "$Subject"
        audiences = @("api://AzureADTokenExchange")
    } | ConvertTo-Json -Depth 10
    $url = "https://graph.microsoft.com/v1.0/applications/$ObjectId/federatedIdentityCredentials"
    $headers = "Content-type=application/json"
    $FedParameters | az rest --method post --uri $url --headers $headers --body '@-'
}
