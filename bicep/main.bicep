// Parameters
param location string = resourceGroup().location
param appServiceName string
param storageAccountName string
param uamiName string

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// User Assigned Managed Identity (UAMI)
resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: uamiName
  location: location
}

// App Service Plan (Free Tier)
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${appServiceName}-plan'
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
  }
}

// App Service
resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uami.id}': {}
    }
  }
}

// Role Assignment: UAMI as Blob Storage Contributor on Storage Account
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(uami.id, storageAccount.id, 'Storage Blob Data Contributor')
  scope: storageAccount
  properties: {
    principalId: uami.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    principalType: 'ServicePrincipal'
  }
}
