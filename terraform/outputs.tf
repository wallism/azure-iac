output "app_service_name" {
  value = azurerm_app_service.appservice.name
}

output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "user_assigned_identity_name" {
  value = azurerm_user_assigned_identity.uami.name
}

output "storage-uami-id"{
    value = azurerm_user_assigned_identity.uami.id
}
output "keyvault-uami-id"{
    value = azurerm_user_assigned_identity.uami_keyvault.id
}
