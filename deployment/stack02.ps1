az login
az account set --name "sub-test-01"

$Stack = az stack sub create `
    --name "deploy-infra" `
    --location 'swedencentral' `
    --subscription 'xxx-1a10-483e-95aa-xxx' `
    --template-file 'main.bicep' `
    --parameters 'param.bicepparam' `
    --delete-all true `
    --yes `
    --delete-resources true `
    --deny-settings-mode none `
    --deny-settings-apply-to-child-scopes `
    --query 'parameters.frontdoorEndpoints.value[].subscriptionId' `
    --output tsv

$Stack | ForEach-Object {
    az automation runbook start --automation-account-name 'aa-prod-01' `
        --name 'run-aa' `
        --parameters EXTSUBID=$_ `
        --resource-group 'rg-aa-prod-01' `
        --subscription 'xxx-be27-46a2-9bb0-xxx'
}
