$Runs = az pipelines runs list --org 'https://dev.azure.com/xxx' --result 'failed' --project 'Operations' --query "[?definition.name=='opsgenie' && contains(startTime, '$(Get-Date -Format "yyyy-MM-dd")')]" 
($Runs | ConvertFrom-Json)[0]
($Runs | ConvertFrom-Json) | ForEach-Object {
    az pipelines run --project 'Operations' --branch 'main' --id $_.definition.id
    Write-Host "Started pipeline: $($_.definition.id)"
}

if ('[]' -eq $Runs ) {
    Write-Host "No failed pipelines"
}
