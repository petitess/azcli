az pipelines build definition list --query "[].name" -o tsv
az pipelines build definition list --query "[?contains(name, 'spoke - CI')].name" -o tsv
az pipelines build definition list --query "[?name=='infra-spoke - CI'].id" -o tsv
