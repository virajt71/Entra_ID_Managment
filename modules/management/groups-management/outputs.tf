output "groups" {
  description = "Created Azure AD groups"
  value = {
    for key, group in azuread_group.department_groups : key => {
      id           = group.id
      display_name = group.display_name
      description  = group.description
    }
  }
}

output "group_ids" {
  description = "Map of department names to group IDs"
  value = {
    for key, group in azuread_group.department_groups : key => group.id
  }
}

output "group_members_count" {
  description = "Count of members in each group"
  value = {
    for key, config in local.groups_config : key => length(config.members)
  }
}

output "subscription_owner" {
  description = "Object ID of the subscription owner (group owner)"
  value       = local.subscription_owner
}

output "departments_processed" {
  description = "List of departments that were processed"
  value       = keys(local.groups_config)
}
