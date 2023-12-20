az login
az account set --name "sub-test-01"

$AZ = az deployment sub create `
    --name "Deploy$(Get-Date -Format 'yyyy-MM-dd')" `
    --subscription '0dcc13b7-1a10-483e-95aa-fe7e71802e2e' `
    --location 'swedencentral' `
    --template-file 'main.bicep' `
    --parameters 'param.bicepparam' `
    --output json

$ExtSubId = ($AZ | ConvertFrom-Json).properties.outputs.fd.value.subscriptionId

$ExtSubId | Where-Object {
    
    az automation runbook start --automation-account-name 'aa-prod-01' `
        --name 'run-aa' `
        --parameters SubId=$_ `
        --resource-group 'rg-aa-prod-01' `
        --subscription 'b2f0f1dc-be27-46a2-9bb0-e80270acfaa0'
}
