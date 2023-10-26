$repoId = az repos list --query "[?name=='ssg-infra'].id" -o tsv
$buildId = az pipelines build definition list --query "[?name=='infra-spoke - CI'].id" -o tsv

az repos policy build create --blocking true `
                             --branch "refs/heads/main" `
                             --build-definition-id $buildId `
                             --display-name "infra - CI" `
                             --enabled true `
                             --manual-queue-only false `
                             --queue-on-source-update-only false `
                             --repository-id $repoId `
                             --valid-duration "0.0" `
                             --path-filter "/ci/ci.yml;/iac/*"
