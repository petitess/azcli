az stack sub create `
        --name 'frontdoor' `
        --location $Config.location `
        --subscription $Config.subscription.$Environment `
        --template-file $TemplateFile `
        --parameters $ParameterFile `
        --delete-all true `
        --yes `
        --delete-resources true `
        --deny-settings-mode none `
        --deny-settings-apply-to-child-scopes `
        --output none

    $Stack = az stack sub show --name "frontdoor" `
        --query 'parameters' `
        --output json
    $frontdoorEndpoints = $Stack | ConvertFrom-Json
    
    $frontdoorEndpoints.config.value.frontdoorEndpoints.subscriptionId | Select-Object -Unique | ForEach-Object {
        az automation runbook start --automation-account-name "aa-infra-mgmt-$($Environment)-we-01" `
            --name "run-ApprovePep01" `
            --parameters EXTSUBID=$_ `
            --resource-group "rg-infra-mgmt-$($Environment)-we-01" `
            --subscription $Config.subscription.$Environment
    }
