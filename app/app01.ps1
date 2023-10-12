$spiname = "sp-serviceaccess-prod-01"
$appId = az ad app list --query "[?displayName=='$spiname'].id" -o tsv

if ($app) {
    Write-Output "Found: $appId"
}else{
    Write-Output "Not Found"
}
