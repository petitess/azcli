az devops user list --query "items" -o tsv
az devops user list --query "items[].user.descriptor" -o tsv
az devops user list --query "items[].user.principalName" -o tsv
az devops user list --query "items[].{principalName:user.principalName, descriptor:user.descriptor}" | Out-File groups.json
az devops user list --query "items[].{principalName:user.principalName, descriptor:user.descriptor}" --output table
az devops user list --query "items[?user.principalName=='kar.sek.ext@xxx.se'].user.descriptor" -o tsv
