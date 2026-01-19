# Groups Management Outputs
output "groups_created" {
  description = "Information about created department groups"
  value       = module.groups_management.groups
}

output "group_ids" {
  description = "Map of department names to group IDs"
  value       = module.groups_management.group_ids
}

output "group_membership_summary" {
  description = "Summary of group memberships"
  value = {
    for dept, count in module.groups_management.group_members_count : dept => {
      department   = dept
      member_count = count
    }
  }
}

output "subscription_owner_info" {
  description = "Object ID of the subscription owner (owner of all groups)"
  value = {
    object_id = module.groups_management.subscription_owner
    message   = "This user is the owner of all department groups"
  }
}

output "departments_processed" {
  description = "List of departments that were processed for group creation"
  value       = module.groups_management.departments_processed
}
