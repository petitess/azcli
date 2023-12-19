## azcli
```
az account show
az account list
az login
az logout
$SubId = az account subscription list --query "[?displayName=='sub-infra-dev-01' && state=='Enabled'].id" -o tsv
$SubName = az account subscription list --query "[?displayName=='sub-infra-dev-01'].displayName" -o tsv
az account set --name $SubName
```
```cs
$subName = "sub-xxx-test-01"
$subId = az account list --query "[?name=='$subName'].id" -o tsv
$Timestamp = Get-Date -Format 'yyyy-MM-dd'
az deployment sub 'create' `
    --name "Deploy_$Timestamp" `
    --subscription $subId `
    --location "swedencentral" `
    --template-file "main.bicep" `
    --parameters "param.bicepparam" `
    --no-prompt `
    --output table
```
