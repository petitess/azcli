az ad app list --all --query "[?displayName=='sp-governance-01'].{displayName:displayName, id:id, appId:appId}" | ConvertFrom-Json
$AppRegObjectId = "abc"
$AppRegAppId = "def"
$body = ConvertTo-Json -Depth 10 @{
    passwordCredential = @{
        displayName   = "secret-$(Get-Date -Format "yyyyMMddHHmm")"
        endDateTime   = (Get-Date).AddYears(50).ToString("o")
        startDateTime = (Get-Date).ToString("o")
    }
}

az rest --method get --uri "https://graph.microsoft.com/v1.0/applications?`$filter=appId eq '$AppRegAppId'" --query "value[].id" -o tsv
az rest --method get --uri "https://graph.microsoft.com/v1.0/applications?`$filter=appId eq '$AppRegAppId'" --query "value[].passwordCredentials"
# Add Password
$headers = "Content-type=application/json"
$url = "https://graph.microsoft.com/v1.0/applications/$AppRegObjectId/addPassword"
$newPassword = $body | az rest --method post --uri $url --headers $headers --body '@-' #--query secretText
$newPassword
# Remove Password
$body = ConvertTo-Json -Depth 10 @{
    keyId = "17a63528-5e1a-4e0b-8873-112524b043a0"
}
$url = "https://graph.microsoft.com/v1.0/applications/$AppRegObjectId/removePassword"
$removePassword = $body | az rest --method post --uri $url --headers $headers --body '@-'
