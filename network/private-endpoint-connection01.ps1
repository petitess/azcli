az network private-endpoint-connection list -n 'stinfraspokedevwe01' -g 'rg-infra-st-dev-we-01' --type "Microsoft.Storage/storageAccounts"

$StId = az storage account list --query "[].id" -o tsv
$StId | ForEach-Object {
    $PepId = az network private-endpoint-connection list --id $_ --query "[?properties.privateLinkServiceConnectionState.status=='Pending'].id"
    az network private-endpoint-connection approve --id $PepId
}
