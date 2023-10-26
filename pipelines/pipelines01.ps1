az extension add --name azure-devops

$Products = (Get-ChildItem -Path './landingzones').Name
$System = 'spoke'

foreach ($Product in $Products) {
    if (!(az pipelines show  --name "$Product-$System - CI" 2> $null)) {
        az pipelines create --name "$Product-$System - CI" --yml-path "landingzones/$Product/ci.yml" --folder-path $Product
    }

    if (!(az pipelines show  --name "$Product-$System - CD" 2> $null)) {
        az pipelines create --name "$Product-$System - CD" --yml-path "landingzones/$Product/cd.yml" --folder-path $Product
    }
}
