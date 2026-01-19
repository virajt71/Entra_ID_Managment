output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.name
}

output "log_analytics_workspace_primary_key" {
  description = "Primary shared key of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}

output "data_collection_rule_id" {
  description = "ID of the Data Collection Rule"
  value       = azurerm_monitor_data_collection_rule.this.id
}

output "data_collection_rule_name" {
  description = "Name of the Data Collection Rule"
  value       = azurerm_monitor_data_collection_rule.this.name
}
