targetScope = 'subscription'

param env string
param param object
param identities array

var location = param.location
var affix = toLower('groups-${param.tags.Environment}')

resource rgInfra 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-01'
}

resource rgId 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-id-${env}-01'
}

module mId 'id.bicep' = [for id in identities: {
  name: id.name
  scope: rgId
  params: {
    name: id.name
    location: location
    tags: param.tags
  }
}]

output mIdPrincipal array = [for (id, i) in identities: {
  name: id.name
  objectId: mId[i].outputs.principalId
  groupName: id.groupName
}]
