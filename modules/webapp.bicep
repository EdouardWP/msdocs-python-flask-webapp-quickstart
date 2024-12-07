@description('The name of the web app')
param name string

@description('The location of the web app')
param location string

@description('The name of the app service plan')
param appServicePlanName string

@description('The SKU of the app service plan')
param sku object = {
  capacity: 1
  family: 'B'
  name: 'B1'
  size: 'B1'
  tier: 'Basic'
}

@description('The container registry image name')
param containerRegistryImageName string

@description('The container registry image version')
param containerRegistryImageVersion string = 'latest'

@description('The container registry name')
param containerRegistryName string

@description('The container registry login server')
param containerRegistryLoginServer string

@description('The container registry admin username')
param containerRegistryUsername string

@description('The container registry admin password')
@secure()
param containerRegistryPassword string

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: sku
  kind: 'linux'
  properties: {
    reserved: true
  }
}

// Web App
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  kind: 'app'
  properties: {
    serverFarmId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
      appSettingsKeyValuePairs: {
        WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
        DOCKER_REGISTRY_SERVER_URL: 'https://${containerRegistryLoginServer}'
        DOCKER_REGISTRY_SERVER_USERNAME: containerRegistryUsername
        DOCKER_REGISTRY_SERVER_PASSWORD: containerRegistryPassword
      }
    }
  }
}

output webAppName string = webApp.name
