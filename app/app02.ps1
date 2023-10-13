$devopsOrgName = "xxxse"
$devopsProjectName = "Infrastruktur"
$issuer = "https://vstoken.dev.azure.com/xxx-823d-4a0d-9191-xxxx"
$spiname = "sp-xxx-test-02"

$appId = az ad app create --display-name $spiname --query "id" -o tsv

$app = az ad app federated-credential list --id $appId --query "[?name=='devops'].id" -o tsv

if ($app) {
    Write-Output "Federated credentials exist"
}
else {
    az ad app federated-credential create --id $appId --parameters `
        "{\""name\"": \""devops\"", \""issuer\"": \""$issuer\"", \""subject\"": \""sc://$devopsOrgName/$devopsProjectName/$spiname\"", \""audiences\"": [\""api://AzureADTokenExchange\""]}"
}
