@description('The name of the App Service')
param name string

@description('The location for the App Service')
param location string

@description('The name of the App Service Plan')
param appServicePlanName string

@description('The name of the container registry')
param containerRegistryName string

@description('The name of the container image')
param containerRegistryImageName string

@description('The version/tag of the container image')
param containerRegistryImageVersion string

@description('The Docker registry server URL')
@secure()
param dockerRegistryServerUrl string

@description('The Docker registry server username')
@secure()
param dockerRegistryServerUserName string

@description('The Docker registry server password')
@secure()
param dockerRegistryServerPassword string

var dockerAppSettings = {
  DOCKER_REGISTRY_SERVER_URL: dockerRegistryServerUrl
  DOCKER_REGISTRY_SERVER_USERNAME: dockerRegistryServerUserName
  DOCKER_REGISTRY_SERVER_PASSWORD: dockerRegistryServerPassword
  WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' existing = {
  name: appServicePlanName
}

resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appSettings: [for setting in items(dockerAppSettings): {
        name: setting.key
        value: setting.value
      }]
    }
  }
}

output id string = appService.id
output name string = appService.name
output defaultHostName string = appService.properties.defaultHostName
