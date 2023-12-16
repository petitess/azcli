Connect-AzAccount -Identity

$RG = Get-AzResourceGroup `
| Where-Object { $_.ResourceGroupName -ne "rg-aa-prod-01" -and `
        $_.ResourceGroupName -ne "rg-asp-prod-01" -and `
        $_.ResourceGroupName -ne "rg-func-prod-01" -and `
        $_.ResourceGroupName -ne "rg-st-prod-01" -and `
        $_.ResourceGroupName -ne "rg-owner-prod-01" }

$RG | ForEach-Object {
    $Remove = Remove-AzResourceGroup -Name $_.ResourceGroupName -Force
    if($Remove) {
    Write-Output "Removed: $($_.ResourceGroupName)"
    }else {
        Write-Output "Didn't remove: $($_.ResourceGroupName)"
    }
}