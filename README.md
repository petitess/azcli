## azcli
```
az account show
az account list
az login
az logout
az account set --name
```
```cs
$subName = "sub-b3care-test-01"
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
