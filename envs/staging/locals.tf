locals {
  env         = "staging"
  location    = "northeurope"
  name_prefix = "app-${local.env}"

  common_tags = {
    environment = local.env
    managed_by  = "terraform"
  }
}
