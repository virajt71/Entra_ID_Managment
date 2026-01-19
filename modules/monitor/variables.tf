variable "name" {
  description = "Prefix for resource names"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "target_vm_id" {
  description = "ID of the VM to associate with the Data Collection Rule"
  type        = string
}

variable "log_analytics_sku" {
  description = "SKU for Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 60
}

variable "syslog_facility_names" {
  description = "List of syslog facility names to collect"
  type        = list(string)
  default = [
    "auth",
    "authpriv",
    "cron",
    "daemon",
    "kern",
    "syslog",
    "user",
    "local0",
    "local1",
    "local2",
    "local3",
    "local4",
    "local5",
    "local6",
    "local7"
  ]
}

variable "syslog_log_levels" {
  description = "List of syslog log levels to collect"
  type        = list(string)
  default = [
    "Debug",
    "Info",
    "Notice",
    "Warning",
    "Error",
    "Critical",
    "Alert",
    "Emergency"
  ]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
