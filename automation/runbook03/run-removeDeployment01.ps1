Connect-AzAccount -Identity

$subscriptions = (Get-AzSubscription | Where-Object {$_.Name -like "sub*"}).Name

$subscriptions | ForEach-Object {
    $con = Set-AzContext -Subscription $_
    Write-Output "$(($con.Subscription.Name).ToUpper()):"
    $Temp = (Get-date).AddDays(-14)
    $date = Get-Date $Temp -Format "yyyy/MM/dd HH:mm:ss"
    $deploy = Get-AzDeployment | Where-Object { $_.Timestamp -lt $date }
    $deploy | ForEach-Object {
        Remove-AzDeployment -Name $_.DeploymentName
        Write-Output "Removed: $($_.DeploymentName)"
    }
    $RGs = Get-AzResourceGroup
    $RGs | ForEach-Object {
        Write-Output "$(($_.ResourceGroupName).ToUpper()):"
        $deployRg = Get-AzResourceGroupDeployment -ResourceGroupName $_.ResourceGroupName | Where-Object { $_.Timestamp -lt $date }
        $deployRg | ForEach-Object {
            Remove-AzResourceGroupDeployment -ResourceGroupName $_.ResourceGroupName -Name $_.DeploymentName
            Write-Output "Removed: $($_.DeploymentName)"
        }
    }
}