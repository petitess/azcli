if ($Command -eq 'create' -and ($deployment | ConvertFrom-Json).properties.provisioningState -eq "Succeeded") {
    az account set --subscription $Config.subscription.$Environment
    $StorageAccountIds = az storage account list --query [].id --output tsv
    $StorageAccountIds  | ForEach-Object {

        $Peps = az network private-endpoint-connection list --id $_ --query "[?properties.privateLinkServiceConnectionState.status=='Pending'].id" --output tsv
        $Peps | ForEach-Object {
            az storage account private-endpoint-connection approve  --id $_ --description "Approved by deploy.ps1"
        }
    } 
}
