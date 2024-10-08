// Parameters
param environment string
param location string = resourceGroup().location
param appServiceName string
param storageAccountName string
param uamiName string
param keyVaultName string
param keyVaultUamiName string

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${environment}${storageAccountName}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// User Assigned Managed Identity (UAMI) for App Service
resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${environment}-${uamiName}'
  location: location
}

// Key Vault UAMI
resource keyVaultUami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${environment}-${keyVaultUamiName}'
  location: location
}

// App Service Plan (Free Tier)
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${environment}-${appServiceName}-plan'
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
  }
  kind: 'linux'
  properties: {
    reserved: true // Indicates Linux
  }
}


// App Service configured for Container deployment
resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: '${environment}-${appServiceName}'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|hello-world:latest' // Specify your container image
    }
  }
  kind: 'app,linux,container'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uami.id}': {}             // Existing UAMI
      '${keyVaultUami.id}': {}     // Key Vault UAMI
    }
  }
}

// Key Vault with Azure RBAC enabled
resource keyVault 'Microsoft.KeyVault/vaults@2022-11-01' = {
  name: '${environment}-${keyVaultName}'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    accessPolicies: []
  }
}

// Create a secret in Key Vault
resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2022-11-01' = {
  name: 'TestSecret'
  parent: keyVault
  properties: {
    value: 'mytestvalue'
  }
}

// Role Assignment: UAMI as Blob Storage Contributor on Storage Account
resource roleAssignmentBlob 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(uami.id, storageAccount.id, 'Storage Blob Data Contributor')
  scope: storageAccount
  properties: {
    principalId: uami.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    principalType: 'ServicePrincipal'
  }
}

// Role Assignment: Key Vault UAMI for Reader on Key Vault
resource roleAssignmentReader 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(keyVaultUami.id, keyVault.id, 'Reader')
  scope: keyVault
  properties: {
    principalId: keyVaultUami.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7') // Reader Role
    principalType: 'ServicePrincipal'
  }
}

// Role Assignment: Key Vault UAMI for Key Vault Secrets User on Key Vault
resource roleAssignmentSecretsUser 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(keyVaultUami.id, keyVault.id, 'KeyVault Secrets User')
  scope: keyVault
  properties: {
    principalId: keyVaultUami.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7') // Key Vault Secrets User Role
    principalType: 'ServicePrincipal'
  }
}
