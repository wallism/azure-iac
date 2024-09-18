# Variables
$resourceGroupName = "dev-azureiac-bicep"
$location = "Australia East"
$appServiceName = "dev-app-azureiac-bicep-ause"
#$keyvaultName = "dev-kv-azureiac-bicep-ause"
$storageAccountName = "devstazureiacbicepause" #max 24 char
$uamiName = "devstoreazureiacausebicep-uami"
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
  uamiName=$uamiName
