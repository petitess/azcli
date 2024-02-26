az login
az account set --name "sub-test-01"

$Command = 'create'
$SubId = az account list --query "[?name=='sub-test-01'].id" --output tsv
$AZ = az deployment sub $Command `
    --name "Deploy$(Get-Date -Format 'yyyy-MM-dd')" `
    --subscription $SubId `
    --location 'swedencentral' `
    --template-file 'main.bicep' `
    --parameters 'param.bicepparam' `
    --output json

$MIdentities = ($AZ | ConvertFrom-Json).properties.outputs.mIdPrincipal.value

if ($Command -eq 'create') {
    $MIdentities | ForEach-Object {
        $GroupName = $_.groupName
        $ObjectId = $_.objectId
        $IdentityName = $_.name

        $Group = az ad group list --query "[?displayName=='$GroupName']" -o tsv
        if ($null -eq $Group) {
            $GroupId = az ad group create --display-name $GroupName --mail-nickname $GroupName --query 'id' -o tsv
            Write-Output "Created $GroupName"
            Write-Output "$GroupName : $GroupId"
        }
        else {
            Write-Output "$GroupName already exists"
        }

        $Assigned = az ad group member check --group $GroupName --member-id $ObjectId --output tsv
        if ($Assigned -eq 'False') {
            $Assigned
            az ad group member add --group $GroupName --member-id $ObjectId
            Write-Output "$IdentityName added to $GroupName "
        }
        else {
            Write-Output "$IdentityName already exists in $GroupName"
        }
    }
}