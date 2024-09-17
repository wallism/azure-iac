# Variables
$resourceGroupName = "myResourceGroup"
$location = "EastUS"
$appServiceName = "myAppService"
$storageAccountName = "mystorageacct"
$uamiName = "myuami"
$templateFile = "main.bicep"

# Create Resource Group (if not exists)
az group create --name $resourceGroupName `
  --location $location

# Deploy the Bicep template
az deployment group create `
  --resource-group $resourceGroupName `
  --template-file $templateFile `
  --parameters location=$location `
  appServiceName=$appServiceName `
  storageAccountName=$storageAccountName `
  uamiName=$uamiName
