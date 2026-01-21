#az login --identity --query "[0].name" -o tsv #Group.ReadWrite.All, For automation account

$spObjectId  = "abc"
$Groups = az ad group list --query "[?contains(displayName, 'grp-az-pbi-ws-')].{displayName: displayName, id:id}" | ConvertFrom-Json

$Groups[0] | ForEach-Object {
    Write-Host "Checking owners for $($_.displayName)"
    $Empty = az rest --method GET --uri "https://graph.microsoft.com/beta/groups/$($_.id)/owners" --query "value[?id=='$spObjectId'].id" -o tsv
    if($null -eq $Empty) {
        Write-Host "Adding owner for $($_.displayName)"
        az ad group owner add --group $_.id --owner-object-id $spObjectId
    }else{
        Write-Host "Owner already exists for group $($_.displayName)"
    }
}
