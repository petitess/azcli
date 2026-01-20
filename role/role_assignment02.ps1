$VmCloudockitObjectId = "abc"

$Subscription = az account list --query "[?contains(name,'-prod-') && name!='sub-platform-prod-01' && state=='Enabled']" | ConvertFrom-Json
$Subscription[0] | ForEach-Object {
    az account set --subscription $_.id
    $SubName = $_.name

    $Reader = az role assignment list --assignee-object-id $VmCloudockitObjectId --query "[?roleDefinitionName=='Reader' && scope=='/subscriptions/$($_.id)']" | ConvertFrom-Json | ForEach-Object {
        Write-Output "Reader role already exists: $($SubName)"
    }
    $Reader

    if ($Reader.Count -eq 0) {
        Write-Output "Assigning Reader role: $($SubName)"

        az role assignment create --assignee $VmCloudockitObjectId --role "Reader" --scope "/subscriptions/$($_.id)" --query "id"
    }

    $BillingReader = az role assignment list --assignee-object-id $VmCloudockitObjectId --query "[?roleDefinitionName=='Billing Reader' && scope=='/subscriptions/$($_.id)']" | ConvertFrom-Json | ForEach-Object {
        Write-Output "Billing Reader role already exists: $($SubName)"
    }
    $BillingReader

    if ($BillingReader.Count -eq 0) {
        Write-Output "Assigning Billing Reader role: $($SubName)"
        az role assignment create --assignee $VmCloudockitObjectId --role "Billing Reader" --scope "/subscriptions/$($_.id)" --query "id"
    }
}
