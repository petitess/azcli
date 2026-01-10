$accessToken = az account get-access-token --resource https://graph.microsoft.com/ --query accessToken -o tsv
$spObjectId = "6bd0c4a1-6983-4640-9e20-6d1a344b78cf"
$url = "https://graph.microsoft.com/v1.0/servicePrincipals/$spObjectId/appRoleAssignments"
$headers = "Content-type=application/json"
# az rest --method get --uri $url
$spObjectId = az rest --method get --uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=displayName eq 'sp-mg-tenant-root-group'" --query "value[].id" -o tsv
$appRoleId = az rest --method get --uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '00000003-0000-0000-c000-000000000000'" --query "value[].appRoles[?value=='Mail.Send'].id" -o tsv
$mGraphId = az rest --method get --uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '00000003-0000-0000-c000-000000000000'" --query "value[].id" -o tsv

$body = ConvertTo-Json -Depth 10  @{
    "principalId" = $spObjectId
    "resourceId"  = $mGraphId
    "appRoleId"   = $appRoleId
}
$roleAssignment = $body | az rest --method post --uri $url --headers $headers --body '@-' --query id
az rest --method delete --uri "$($url)/$($roleAssignment | ConvertFrom-Json)"
