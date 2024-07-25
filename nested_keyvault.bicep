param name string
param location string = resourceGroup().location
param tags object = {}

@description('Service principal that should be granted read access to the KeyVault. If unset, no service principal is granted access by default')
param principalId string = ''

var defaultAccessPolicies = ((!empty(principalId))
  ? [
      {
        objectId: principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
        tenantId: subscription().tenantId
      }
    ]
  : [])

resource name_resource 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enabledForTemplateDeployment: true
    accessPolicies: union(defaultAccessPolicies, [])
  }
}

output endpoint string = reference(name_resource.id, '2022-07-01').vaultUri
output name string = name
