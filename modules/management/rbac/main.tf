resource "azurerm_role_assignment" "this" {
  for_each = toset(var.roles)

  scope                = var.scope
  role_definition_name = each.value
  principal_id         = var.principal_id
}
