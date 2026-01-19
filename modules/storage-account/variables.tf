variable "name" {
  description = "Resource group name"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.name))
    error_message = "Resource group name can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "location" {
  description = "Azure region"
  type        = string

  validation {
    condition = contains([
      "northeurope", "westeurope", "uksouth", "ukwest"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "account_tier" {
  description = "Resource group name"
  type        = string
}

variable "account_replication_type" {
  description = "Resource group name"
  type        = string
}

variable "allow_nested_items_to_be_public" {
  description = "Resource group name"
  type        = bool
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
