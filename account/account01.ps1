az account list
az account list --query "[].name" -o tsv
az account list --query "[?name=='sub-infra-dev-01']"
az account list --query "[?name=='sub-infra-dev-01'].id" -o tsv
