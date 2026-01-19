variable "team" {
  description = "Team name"
  type        = string
}

variable "environment" {
  description = "Environment (Dev, Staging, Prod)"
  type        = string
}

variable "roles" {
  description = "List of role definitions for the team in the environment"
  type        = list(string)
}

variable "scope" {
  description = "Scope of the role assignment (subscription, resource group, etc.)"
  type        = string
}

variable "principal_id" {
  description = "Object ID of the AAD group or SP representing the team"
  type        = string
}
