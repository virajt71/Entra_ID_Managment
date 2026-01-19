# Get current Azure AD context
data "azuread_client_config" "current" {}

# Create Azure AD Groups for each department
resource "azuread_group" "department_groups" {
  for_each = local.groups_config

  display_name            = each.value.display_name
  description             = each.value.description
  security_enabled        = true
  mail_enabled            = false
  assignable_to_role      = false
  prevent_duplicate_names = true

  # Add subscription owner as group owner
  owners = [local.subscription_owner]

  lifecycle {
    ignore_changes = [
      members # We'll manage members separately to avoid conflicts
    ]
  }
}

# Create individual membership resources for each user-group combination
resource "azuread_group_member" "department_members" {
  for_each = {
    for pair in flatten([
      for group_key, config in local.groups_config : [
        for member_id in config.members : {
          group_key = group_key
          member_id = member_id
          key       = "${group_key}-${substr(member_id, 0, 8)}"
        }
      ]
    ]) : pair.key => pair
  }

  # Use object_id instead of id for both group and member
  group_object_id  = azuread_group.department_groups[each.value.group_key].object_id
  member_object_id = each.value.member_id

  depends_on = [azuread_group.department_groups]
}
