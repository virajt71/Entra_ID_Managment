# Data source to get user information from users terraform state
data "terraform_remote_state" "users" {
  backend = "azurerm"

  config = {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatergregergv"
    container_name       = "tfstate"
    key                  = "root/sub_managment/users/terraform.tfstate"
  }
}

# Get current subscription info for reference
data "azurerm_client_config" "current" {}

# Groups Management Module - Create department groups
module "groups_management" {
  source = "../../modules/management/groups-management"

  # Get departments from users terraform state
  departments = data.terraform_remote_state.users.outputs.departments_found

  # Group users by their departments from users terraform state
  users_by_department = data.terraform_remote_state.users.outputs.users_by_department

  # Group configuration
  group_prefix               = "dept"
  group_description_template = "Department group for {department} team members"

  # Subscription owner will be the owner of all groups
  # Leave empty to use current user, or provide specific object ID
  subscription_owner_id = ""
}
