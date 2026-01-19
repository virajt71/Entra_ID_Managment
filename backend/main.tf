module "resource_group" {
  source = "../modules/resource-group"

  name     = "${local.name}-rg"
  location = local.location

  tags = local.common_tags
}

module "storage_account" {
  source = "../modules/storage-account"

  name                            = "${local.name}rgrege33rgv"
  resource_group_name             = module.resource_group.name
  location                        = module.resource_group.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false

  tags = local.common_tags
}

resource "azurerm_storage_container" "this" {
  name                  = local.name
  storage_account_id    = module.storage_account.id
  container_access_type = "private"
}
