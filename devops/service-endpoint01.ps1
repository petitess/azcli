$devopsOrg = "https://dev.azure.com/xxx"
$project = "Infrastruktur"
$spiname = "sp-labb-01x"
$endpointId = az devops service-endpoint list --org $devopsOrg --project $project --query "[?name=='$spiname'].id" -o tsv 

if ($endpoint) {
    Write-Output "Found: $endpointId"
}else{
    Write-Output "Not Found"
}

###
az devops service-endpoint list --org $devopsOrg --project $project --query "[].name"
