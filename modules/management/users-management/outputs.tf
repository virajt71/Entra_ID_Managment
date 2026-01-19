output "company_info" {
  description = "Company information used for user creation"
  value = {
    company_name   = var.company_name != "" ? var.company_name : data.azuread_domains.tenant_domains.domains[0].domain_name
    company_domain = local.company_domain
    tenant_domain  = data.azuread_domains.tenant_domains.domains[0].domain_name
  }
}

output "user_ids" {
  description = "Map of user keys to their object IDs"
  value = {
    for key, user in azuread_user.users : key => user.id
  }
  sensitive = true
}

output "user_principal_names" {
  description = "Map of user keys to their UPNs"
  value = {
    for key, user in azuread_user.users : key => user.user_principal_name
  }
  sensitive = true
}

output "users" {
  description = "Complete user objects for reference by other modules"
  value       = azuread_user.users
  sensitive   = true
}

output "users_created_count" {
  description = "Number of users created"
  value       = length(azuread_user.users)
}

output "users_summary" {
  description = "Summary of created users"
  value = {
    for key, user in azuread_user.users : key => {
      display_name = user.display_name
      department   = user.department
      job_title    = user.job_title
      upn          = user.user_principal_name
    }
  }
  sensitive = true
}

# NEW: Group users by department for group management
output "users_by_department" {
  description = "Map of departments to list of user object IDs"
  value = {
    for dept in distinct([for user in azuread_user.users : user.department]) : dept => [
      for user in azuread_user.users : user.id if user.department == dept
    ]
  }
  sensitive = true
}

output "departments" {
  description = "List of unique departments from created users"
  value       = distinct([for user in azuread_user.users : user.department])
}
