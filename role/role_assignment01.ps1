az login
az account set --name 'sub-dev-01'
$GroupName = 'grp-dev-maxa-user-PIM-DEV'
$GroupId = az ad group list --query "[?displayName=='$GroupName'].id" -o tsv

$scopes = @(
    [PSCustomObject]@{
        Role  = "Reader"
        Scope = az group show --name "rg-infra-app-dev-sc-01" --query id
    }
    [PSCustomObject]@{
        Role  = "Contributor"
        Scope = az group show --name "rg-integration-dev-sc-01" --query id
    }
    [PSCustomObject]@{
        Role  = "Azure Service Bus Data Owner"
        Scope = az group show --name "rg-integration-dev-sc-01" --query id
    }
    [PSCustomObject]@{
        Role  = "App Configuration Data Owner"
        Scope = az group show --name "rg-integration-dev-sc-01" --query id
    }
    [PSCustomObject]@{
        Role  = "Contributor"
        Scope = az group show --name "rg-func-maxa-dev-sc-01" --query id
    }
    [PSCustomObject]@{
        Role  = "Key Vault Administrator"
        Scope = az group show --name "rg-func-maxa-dev-sc-01" --query id
    }
    [PSCustomObject]@{
        Role  = "Storage Blob Data Contributor"
        Scope = az group show --name "rg-func-maxa-dev-sc-01" --query id
    }
)

$scopes | ForEach-Object {
    az role assignment create --role $_.Role --assignee-object-id $GroupId --scope $_.Scope --assignee-principal-type Group
}
