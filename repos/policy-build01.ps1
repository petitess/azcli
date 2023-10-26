$repoName = 'xxx-infra'
$repoId = az repos list --query "[?name=='$repoName'].id" -o tsv
$pipelineName = 'infra-spoke - CI'
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
