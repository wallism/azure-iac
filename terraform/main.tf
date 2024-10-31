provider "azurerm" {
  features {}
    # Required for authentication
  subscription_id = "584b7ab4-d35f-4eef-ac2e-b88890e8a7fe"

  # Uncomment and fill these in if using a service principal
  # client_id       = "<YOUR_CLIENT_ID>"
  # client_secret   = "<YOUR_CLIENT_SECRET>"
  # tenant_id       = "<YOUR_TENANT_ID>"
}


resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = "Australia East"
}

resource "azurerm_storage_account" "storage" {
  name                     = "devstgaccountause"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_user_assigned_identity" "uami" {
  name                = "dev-kv-azureiac-bicep-ause-uami"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_service_plan" "service_plan" {
  name                = "dev-serviceplan-ause"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  os_type  = "Linux"         # Specify the OS type (use "Windows" if required)
  sku_name = "F1"            # Free tier SKU


}


resource "azurerm_app_service" "appservice" {
  name                = "dev-appservice-ause"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uami.id]
  }
}

resource "azurerm_role_assignment" "blob_contributor" {
  principal_id   = azurerm_user_assigned_identity.uami.principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope          = azurerm_storage_account.storage.id
}
