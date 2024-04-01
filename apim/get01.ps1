az login

az account set --name "sub-infra-dev-01"

az apim api list  --resource-group "rg-infra-apim-dev-we-01" --service-name "apim-infra-apim-dev-we-02"

az apim api schema list --resource-group "rg-infra-apim-dev-we-01" --service-name "apim-infra-apim-dev-we-02" --api-id "ticket-api-v1"

az apim api schema show --resource-group "rg-infra-apim-dev-we-01" --service-name "apim-infra-apim-dev-we-02" --api-id "ticket-api-v1" --schema-id 65f852a34634611bdc2932df
