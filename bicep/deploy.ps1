# Variables
$environment = "dev"
$resourceGroupName = "${environment}-azureiac-bicep"
$location = "Australia East"
$appServiceName = "app-azureiac-bicep-ause"
$storageAccountName = "stazureiacbicepause"
$uamiName = "stazureiacbicepause-uami"
$keyVaultName = "kv-azureiac-bicep"
$keyVaultUamiName = "kv-azureiac-bicep-uami"
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
  keyVaultUamiName=$keyVaultUamiName `
  environment=$environment
