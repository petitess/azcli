$devopsOrg = "https://dev.azure.com/xxxse"
$devopsProjectName = "Infrastruktur"

az devops configure --defaults organization=$devopsOrg project=$devopsProjectName

#az devops user list	| Out-File users.json

#az devops security group list --scope organization | Out-File groups.json

$groupDescriptor = "vssgp.Uy0xLTktMTU1MTM3NDI0NS0xODU1OTU2NTEyLTEwMzE5MzMyNTgtMjQ0MjI0OTg1OS03OTxxxxxxxxxxxxx"
$userDescriptor = "aad.YzY2MTQzNTEtM2U5MS03MzUxLWE3MjItOTE5NWExxx"

az devops security group membership add --org $devopsOrg --group-id $groupDescriptor --member-id $userDescriptor
