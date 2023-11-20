$token = az account get-access-token --query accessToken --output tsv
$devopsOrg = "xxx"
$devopsUrl = "https://dev.azure.com/$devopsOrg"
$poolId = az pipelines pool list --query "[?name=='vmss-infra-devops-dev-we-01'].id" --org $devopsUrl --output tsv

az rest --method "get" --uri "https://dev.azure.com/${devopsOrg}/_apis/distributedtask/pools?api-version=7.1-preview.1" --headers "Authorization =Bearer $token" "Content-Type =application/json" 

az rest --method "get" --uri "https://dev.azure.com/${devopsOrg}/_apis/distributedtask/pools/${poolId}?api-version=7.1-preview.1" --headers "Authorization =Bearer $token" "Content-Type =application/json" 

$uri = "https://dev.azure.com/${devopsOrg}/_apis/distributedtask/pools/${poolId}?api-version=7.1-preview.1"
Invoke-RestMethod  -Method GET -Uri $uri  -Headers @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" }
