```pwsh
$Body = ConvertTo-Json -Compress @{
    Properties = @{
        targetServerAzureResourceId = "/subscriptions/123/resourceGroups/rg-pulumi-sql-dev-01/providers/Microsoft.Sql/servers/sql-pulumi-dev-01"
    }
}

az rest --method put `
     --url https://management.azure.com/subscriptions/64854628-b6d8-431f-b2a6-13596afbfabb/resourceGroups/rg-pulumi-sql-dev-01/providers/Microsoft.Sql/servers/sql-pulumi-dev-01/jobAgents/sqlja-db-app/privateEndpoints/pep-sqlja-db-app?api-version=2023-08-01 `
     --body $($Body | ConvertTo-Json)
    #  --body "{'properties': {'targetServerAzureResourceId': '/subscriptions/123/resourceGroups/rg-pulumi-sql-dev-01/providers/Microsoft.Sql/servers/sql-pulumi-dev-01'}}"
```
