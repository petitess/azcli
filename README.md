## login
```pwsh
az account show
az account list
az login
az logout
$SubId = az account subscription list --query "[?displayName=='sub-infra-dev-01' && state=='Enabled'].id" -o tsv
$SubName = az account subscription list --query "[?displayName=='sub-infra-dev-01'].displayName" -o tsv
az account set --name $SubName
```
## deployment
```pwsh
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
## query
```pwsh
az --query "[].name" -o tsv
az --query "[?name=='sub-infra-dev-01']"
az --query "[?name=='sub-infra-dev-01'].id" -o tsv
az --query "[?isDefault]"
az --query "[?displayName=='$spiname'].id" --all -o tsv
az --query "[?name=='devops'].id" -o tsv
az --query [].appId -o tsv
az --query "graphGroups" -o tsv
az --query "graphGroups[?contains(principalName,'Infrastruktur')].{principalName: principalName}" -o tsv
az --query "graphGroups" -o tsv
az --query "graphGroups[].{displayName:displayName, descriptor:descriptor}" --output table
az --query "graphGroups[?contains(principalName,'XXX')].{principalName: principalName}" -o tsv
az --query "graphGroups[?displayName=='Project Collection Administrators'].descriptor" -o tsv
az --query "graphGroups[?principalName=='[orgxxx]\Project Collection Administrators'].descriptor" -o tsv
az --query "graphGroups[?contains(principalName,'Project Collection Administrators')].descriptor" -o tsv
az --query [?privateLinkServiceConnectionState.status=='Approved'].id
```
