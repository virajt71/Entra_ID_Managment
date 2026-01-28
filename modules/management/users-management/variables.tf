variable "company_name" {
  description = "Company name for user profiles (if empty, will use tenant domain)"
  type        = string
  default     = ""
}

variable "company_domain" {
  description = "Company domain for email generation (if empty, will be derived from company_name or tenant)"
  type        = string
  default     = ""
}

variable "usage_location" {
  description = "Usage location for users (required for license assignment)"
  type        = string
  default     = "US"
}

variable "default_password" {
  description = "Default password for users if not specified in CSV. REQUIRED: Provide via -var or tfvars. DO NOT hardcode passwords in production."
  type        = string
  sensitive   = true
  validation {
    condition     = var.default_password != ""
    error_message = "default_password must be provided and non-empty. Consider using Azure Key Vault to store and retrieve passwords securely."
  }
}

variable "users" {
  description = "Map of users to create (alternative to CSV file)"
  type = map(object({
    given_name            = string
    surname               = string
    job_title             = string
    department            = string
    force_password_change = optional(bool, true)
  }))
  default   = {}
  sensitive = true
}

variable "csv_file_path" {
  description = "Path to CSV file containing user data"
  type        = string
  default     = ""
}

