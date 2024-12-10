@description('Required. Name of your Azure Container Registry.')
@minLength(5)
@maxLength(50)
param name string

@description('Enable admin user that have push / pull permission to the registry.')
param acrAdminUserEnabled bool = true

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('The name of the App Service')
param appServiceName string

@description('The name of the container image')
param containerRegistryImageName string

@description('The version/tag of the container image')
param containerRegistryImageVersion string

@description('The name of the Key Vault')
param keyVaultName string

module keyVaultModule './key-vault.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    name: keyVaultName
    location: location
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

module containerRegistry 'modules/container-registry.bicep' = {
  name: 'containerRegistryDeployment'
  params: {
    name: name
    location: location
    acrAdminUserEnabled: acrAdminUserEnabled
    adminCredentialsKeyVaultResourceId: keyVaultModule.outputs.keyVaultId
    adminCredentialsKeyVaultSecretUserName: 'acr-admin-username'
    adminCredentialsKeyVaultSecretUserPassword1: 'acr-admin-password1'
    adminCredentialsKeyVaultSecretUserPassword2: 'acr-admin-password2'
  }
  dependsOn: [
    keyVaultModule
  ]
}

module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'appServicePlanEdou'
  params: {
    name: 'appServicePlanEdou'
    location: location
    sku: {
      name: 'B1'
      capacity: 1
      family: 'B'
      size: 'B1'
      tier: 'Basic'
    }
  }
}

module appService 'modules/app-service.bicep' = {
  name: 'appServiceEdou'
  params: {
    name: appServiceName
    location: location
    appServicePlanName: appServicePlan.name
    containerRegistryName: name
    containerRegistryImageName: containerRegistryImageName
    containerRegistryImageVersion: containerRegistryImageVersion
    dockerRegistryServerUrl: 'https://${containerRegistry.outputs.loginServer}'
    dockerRegistryServerUserName: keyVault.getSecret('acr-admin-username')
    dockerRegistryServerPassword: keyVault.getSecret('acr-admin-password1')
  }
  dependsOn: [
    containerRegistry
    keyVaultModule
  ]
}

output containerRegistryLoginServer string = containerRegistry.outputs.loginServer
output appServiceId string = appService.outputs.id
output appServiceName string = appService.outputs.name
output appServiceDefaultHostName string = appService.outputs.defaultHostName
