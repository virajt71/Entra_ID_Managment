output "rg_name" {
  value = module.resource_group.name
}

output "sa_name" {
 value = module.storage_account.sa_name
}

output "container_name" {
  value = azurerm_storage_container.this.name
}
