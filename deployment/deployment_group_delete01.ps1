az login --identity --output tsv --query name

az account set --name "sub-test-01" --output tsv --query name

$SDeployments = az deployment sub list --output tsv --query [].name

$SDeployments 

$SDeployments | ForEach-Object {
    az deployment sub delete --name $_
}


az login --identity --output tsv --query name

az account set --name "sub-test-01" --output tsv --query name

$RGs = az group list --output tsv --query [].name

$RGs | ForEach-Object {
    ($_).ToUpper()
    $SDeployments = az deployment group list --resource-group $_ --output tsv --query [].name
    $RgName = $_
    $SDeployments | ForEach-Object {
        Write-Output "D: $($_)"
        az deployment group delete --name $_ --resource-group $RgName
    }
}
