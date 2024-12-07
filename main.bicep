targetScope = 'subscription'

@description('The environment name. "dev" and "prod" are valid values.')
param environmentName string = 'dev'

@description('The Azure region into which the resources should be deployed.')
param location string = 'westeurope'

@description('The name of the resource group to create.')
param resourceGroupName string = 'rg-${environmentName}'

// Variables for naming
var acrName = 'acr${environmentName}${uniqueString(subscription().id)}'
var appServicePlanName = 'plan-${environmentName}'
var webAppName = 'app-${environmentName}'
var containerImageName = 'flask-app'
var containerImageVersion = 'latest'

// Create Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

// Deploy Azure Container Registry
module acr 'modules/acr.bicep' = {
  scope: rg
  name: 'acrDeployment'
  params: {
    name: acrName
    location: location
    acrAdminUserEnabled: true
  }
}

// Deploy Web App
module webApp 'modules/webapp.bicep' = {
  scope: rg
  name: 'webAppDeployment'
  params: {
    name: webAppName
    location: location
    appServicePlanName: appServicePlanName
    containerRegistryName: acrName
    containerRegistryImageName: containerImageName
    containerRegistryImageVersion: containerImageVersion
    containerRegistryLoginServer: acr.outputs.loginServer
    containerRegistryUsername: acr.outputs.adminUsername
    containerRegistryPassword: acr.outputs.adminPassword
  }
}
