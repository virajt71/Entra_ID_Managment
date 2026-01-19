# Monitoring Module - Creates Log Analytics Workspace, DCR, and DCR Association

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.name}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

# Data Collection Rule for Syslog
resource "azurerm_monitor_data_collection_rule" "this" {
  name                = "${var.name}-dcr"
  resource_group_name = var.resource_group_name
  location            = var.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.this.id
      name                  = "log-analytics-destination"
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["log-analytics-destination"]
  }

  data_sources {
    syslog {
      facility_names = var.syslog_facility_names
      log_levels     = var.syslog_log_levels
      name           = "syslog-datasource"
      streams        = ["Microsoft-Syslog"]
    }
  }

  tags = var.tags
}

# Associate DCR with VM
resource "azurerm_monitor_data_collection_rule_association" "this" {
  name                    = "${var.name}-dcr-association"
  target_resource_id      = var.target_vm_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.this.id
}

# Azure Monitor Agent Extension
resource "azurerm_virtual_machine_extension" "this" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = var.target_vm_id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.6"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  tags                       = var.tags
}
