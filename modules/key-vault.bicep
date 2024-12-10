param name string
param location string = resourceGroup().location

@description('Enable vault for deployment')
param enableVaultForDeployment bool = true

@description('Array of role assignment objects')
param roleAssignments array = [
  {
    principalId: '7200f83e-ec45-4915-8c52-fb94147cfe5a'
    roleDefinitionIdOrName: 'Key Vault Secrets User'
    principalType: 'ServicePrincipal'
  }
]

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enabledForDeployment: enableVaultForDeployment
    enabledForTemplateDeployment: true
    enableRbacAuthorization: true
    accessPolicies: []
  }
}

@description('Built-in Key Vault Secrets User Role')
resource keyVaultSecretsUserRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleAssignment in roleAssignments: {
  scope: keyVault
  name: guid(keyVault.id, roleAssignment.principalId, keyVaultSecretsUserRole.id)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRole.id)
    principalId: roleAssignment.principalId
    principalType: roleAssignment.principalType
  }
}]

output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id 
