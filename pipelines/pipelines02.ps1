az extension add --name azure-devops

$Products = (Get-ChildItem -Path './landingzones').Name
$System = 'spoke'

foreach ($Product in $Products) {
    if (!(az pipelines show  --name "$Product-$System - CI" 2> $null)) {
        az pipelines create --name "$Product-$System - CI" --yml-path "landingzones/$Product/ci.yml" --folder-path $Product
    }

    if (!(az pipelines show  --name "$Product-$System - CD" 2> $null)) {
        az pipelines create --name "$Product-$System - CD" --yml-path "landingzones/$Product/cd.yml" --folder-path $Product
    }
}

foreach ($Product in $Products) {
    $repoName = 'ssg-landingzones'
    $repoId = az repos list --query "[?name=='$repoName'].id" -o tsv
    $pipelineName = "$Product-$System - CI"
    $buildId = az pipelines build definition list --query "[?name=='$pipelineName'].id" -o tsv
    $policyValidation = az repos policy list --query "[?settings.displayName=='$pipelineName']" -o tsv

    if ($null -eq $policyValidation) {
        Write-Output "Creating Build Validation policy."
        az repos policy build create --blocking true `
            --branch "refs/heads/main" `
            --build-definition-id $buildId `
            --display-name $pipelineName `
            --enabled true `
            --manual-queue-only false `
            --queue-on-source-update-only false `
            --repository-id $repoId `
            --valid-duration "0.0" `
            --path-filter "/ci/ci.yml;/iac/*"
    }
    else {
        Write-Output "Build Validation policy already exists."
    }
}