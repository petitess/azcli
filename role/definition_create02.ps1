az role definition create --role-definition ('{"Name":"Role Y","IsCustom":true,"Description":"Role X","Actions":["*/read","Microsoft.Authorization/*"],"NotActions":[],"DataActions":[],"NotDataActions":[],"AssignableScopes":["/subscriptions/2d9f44ea-e3df-4ea1-b956-8c7a43b119a0"]}' | ConvertTo-Json)
az role definition delete --name "Role Y"