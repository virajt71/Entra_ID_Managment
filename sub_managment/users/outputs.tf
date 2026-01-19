# User Management Outputs
output "users_created_count" {
  description = "Number of users created"
  value       = module.user_management.users_created_count
}

output "company_information" {
  description = "Company information used for user creation"
  value       = module.user_management.company_info
}

output "departments_found" {
  description = "List of departments found in CSV"
  value       = module.user_management.departments
}

output "users_by_department" {
  description = "Map of departments to list of user object IDs"
  value       = module.user_management.users_by_department
  sensitive   = true
}

output "user_ids" {
  description = "Map of user keys to their object IDs"
  value       = module.user_management.user_ids
  sensitive   = true
}

output "users_summary" {
  description = "Summary of created users with their details"
  value       = module.user_management.users_summary
  sensitive   = true
}
