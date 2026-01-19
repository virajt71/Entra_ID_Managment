# Get current user context
data "azurerm_client_config" "current" {}

locals {
  # Normalize department names for group creation
  normalized_departments = [
    for dept in var.departments : {
      original   = dept
      normalized = lower(replace(dept, " ", "_"))
      display    = dept
    }
  ]

  # Clean user IDs - remove /users/ prefix if present from terraform state
  clean_users_by_department = {
    for dept, user_ids in var.users_by_department : dept => [
      for user_id in user_ids : (
        can(regex("^/users/(.+)$", user_id)) ?
        regex("^/users/(.+)$", user_id)[0] :
        user_id
      )
    ]
  }

  # Create group configuration
  groups_config = {
    for dept in local.normalized_departments : dept.normalized => {
      name         = "${var.group_prefix}-${dept.normalized}"
      display_name = "${dept.display}"
      description  = replace(var.group_description_template, "{department}", dept.display)
      members      = lookup(local.clean_users_by_department, dept.original, [])
    }
  }

  # Determine subscription owner - use provided ID or current user
  subscription_owner = var.subscription_owner_id != "" ? var.subscription_owner_id : data.azurerm_client_config.current.object_id
}
