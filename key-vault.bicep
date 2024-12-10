param name string
param location string = resourceGroup().location

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enableRbacAuthorization: true
    accessPolicies: []
  }
}

output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id 
