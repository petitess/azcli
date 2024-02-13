if ($Command -eq 'create') {
    #Vnet peering resync - landing zones
    $Peerings = az network vnet peering list `
        -g "rg-$LandingZone-spoke-$Environment-we-01" `
        --vnet-name "vnet-$LandingZone-spoke-$Environment-we-01" `
        --query "[?peeringSyncLevel=='LocalNotInSync'].id" `
        --subscription $Config.subscription.$Environment `
        --output tsv

    $Peerings | Where-Object {
        $Syncked = az network vnet peering sync --ids $_ --query "peeringSyncLevel" --output tsv
        Write-Output "$Syncked vnet-$LandingZone-spoke-$Environment-we-01" 
    }
    #Vnet peering resync - platform
    $Peerings = az network vnet peering list `
        -g "rg-platform-hub-prod-we-01" `
        --vnet-name "vnet-platform-hub-prod-we-01" `
        --query "[?peeringSyncLevel=='LocalNotInSync'].id" `
        --subscription "123-ecad-4d1c-8e2b-04523f31826d" `
        --output tsv

    $Peerings | Where-Object {
        $Syncked = az network vnet peering sync --ids $_ --query "peeringSyncLevel" --output tsv
        Write-Output "$Syncked vnet-platform-hub-prod-we-01" 
    }
}
