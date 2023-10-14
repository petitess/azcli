az devops security group list --scope project | Out-File groups.json
az devops security group list --scope project --query "graphGroups" -o tsv
az devops security group list --scope project --query "graphGroups[?contains(principalName,'Infrastruktur')].{principalName: principalName}" -o tsv

az devops security group list --scope organization | Out-File groups.json
az devops security group list --scope organization --query "graphGroups" -o tsv
az devops security group list --scope organization --query "graphGroups[].{principalName:principalName, descriptor:descriptor}"
az devops security group list --scope organization --query "graphGroups[?contains(principalName,'XXX')].{principalName: principalName}" -o tsv
az devops security group list --scope organization --query "graphGroups[?displayName=='Project Collection Administrators'].descriptor" -o tsv
az devops security group list --scope organization --query "graphGroups[?principalName=='[orgxxx]\Project Collection Administrators'].descriptor" -o tsv
az devops security group list --scope organization --query "graphGroups[?contains(principalName,'Project Collection Administrators')].descriptor" -o tsv
