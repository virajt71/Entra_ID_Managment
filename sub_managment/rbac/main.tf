# Get team principals from Azure AD instead of hard-coding
data "azuread_group" "teams" {
  for_each = toset([for assignment in local.rbac_assignments : assignment.team])

  display_name     = each.value
  security_enabled = true
}

# Remote state data sources for each environment
data "terraform_remote_state" "environments" {
  for_each = local.environments

  backend = "azurerm" # Consider using azurerm backend for production
  config = {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatergregergv"
    container_name       = "tfstate"
    key                  = each.value.key
  }
}

# RBAC module instances
module "rbac" {
  for_each = {
    for idx, assignment in local.rbac_assignments :
    "${assignment.team}-${assignment.environment}" => assignment
  }

  source      = "../../modules/management/rbac"
  team        = each.value.team
  environment = each.value.environment
  roles       = each.value.roles

  # Use correct environment scope
  scope        = data.terraform_remote_state.environments[each.value.environment].outputs.resource_group_id
  principal_id = data.azuread_group.teams[each.value.team].object_id
}
