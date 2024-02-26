using 'main.bicep'

param env = 'dev'
param identities = [
  {
    name: 'id-system-01'
    team: 'x'
    groupName: 'grp-rbac-app-itglue-${env}'
  }
  {
    name: 'id-product-01'
    team: 'x'
    groupName: 'grp-rbac-app-itglue-${env}'
  }
  {
    name: 'id-network-01'
    team: 'x'
    groupName: 'grp-rbac-app-esign-${env}'
  }
]
param param = {
  location: 'swedencentral'
  tags: {
    Environment: 'dev'
  }
}
