azcopy login --tenant-id "x-3fc5167644de"
azcopy copy `
'https://stterraform001.blob.core.windows.net/opsgenie-terraform-1-azure/terraform.tfstate' `
'https://stdownload01.blob.core.windows.net/test/terraform2.tfstate'

$env:AZCOPY_SPA_CLIENT_SECRET  = "xUIDiE~35cy4"
azcopy login --service-principal --application-id "x-169d9abf5dd3" --tenant-id "x-3fc5167644de"
azcopy copy `
'https://stterraform0001.blob.core.windows.net/opsgenie-terraform-1-azure/terraform.tfstate' `
'https://stdownload01.blob.core.windows.net/test/terraform3.tfstate'
