az login
az account set --name "sub-test-01"

$AZ = az deployment sub create `
    --name "Deploy$(Get-Date -Format 'yyyy-MM-dd')" `
    --subscription 'xxx-1a10-483e-95aa-xxxx' `
    --location 'swedencentral' `
    --template-file 'main.bicep' `
    --parameters 'param.bicepparam' `
    --output json

$ExtSubId = ($AZ | ConvertFrom-Json).properties.outputs.fd.value.subscriptionId
$ExtSubId | ForEach-Object {

    az automation runbook start --automation-account-name 'aa-prod-01' `
        --name 'run-aa' `
        --parameters EXTSUBID=$_ `
        --resource-group 'rg-aa-prod-01' `
        --subscription 'xxx-be27-46a2-9bb0-xxx'

}
