# Variables
$resourceGroupName = "dev-azureiac-bicep"
$location = "Australia East"
$appServiceName = "dev-app-azureiac-bicep-ause"
$storageAccountName = "devstazureiacbicepause"
$uamiName = "devstazureiacbicepause-uami"
$keyVaultName = "dev-kv-azureiac-bicep"
$keyVaultUamiName = "dev-kv-azureiac-bicep-uami"
$templateFile = "main.bicep"

# Create Resource Group (if not exists)
az group create --name $resourceGroupName --location $location

# Deploy the Bicep template
az deployment group create `
  --resource-group $resourceGroupName `
  --template-file $templateFile `
  --parameters location=$location `
  appServiceName=$appServiceName `
  storageAccountName=$storageAccountName `
  uamiName=$uamiName `
  keyVaultName=$keyVaultName `
  keyVaultUamiName=$keyVaultUamiName
