@description('The name of the container registry')
param name string

@description('The location of the container registry')
param location string

@description('Enable admin user')
param acrAdminUserEnabled bool = true

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

output loginServer string = acr.properties.loginServer
output adminUsername string = acrAdminUserEnabled ? acr.name : ''
output adminPassword string = acrAdminUserEnabled ? listCredentials(acr.id, acr.apiVersion).passwords[0].value : ''
