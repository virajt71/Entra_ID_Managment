output "sa_name" {
  description = "Storage Account name"
  value       = azurerm_storage_account.this.name
}

output "id" {
  description = "Storage Account ID"
  value       = azurerm_storage_account.this.id
}
