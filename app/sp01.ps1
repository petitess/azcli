$spiname = "sp-serviceaccess-prod-01"
$spiID = az ad sp list --display-name $spiname --query [].appId -o tsv

if ($spiID) {
    Write-Output "Found: $spiID"
}else{
    Write-Output "Not Found"
}
