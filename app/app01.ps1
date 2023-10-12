$spiname = "sp-serviceaccess-prod-01"
$appId = az ad app list --query "[?displayName=='$spiname'].id" --all -o tsv

if ($appId) {
    Write-Output "Found: $appId"
}else{
    Write-Output "Not Found"
}
