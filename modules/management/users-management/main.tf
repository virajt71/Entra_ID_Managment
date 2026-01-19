# Get company information from Azure AD tenant
data "azuread_domains" "tenant_domains" {
  only_initial = true
}

# Create Users
resource "azuread_user" "users" {
  for_each = { for user in local.users_from_csv : user.user_key => user }

  user_principal_name   = each.value.user_principal_name
  display_name          = each.value.display_name
  given_name            = each.value.given_name
  surname               = each.value.surname
  mail_nickname         = each.value.mail_nickname
  password              = each.value.password
  force_password_change = each.value.force_password_change

  # Job information
  job_title    = each.value.job_title
  department   = each.value.department
  company_name = var.company_name != "" ? var.company_name : data.azuread_domains.tenant_domains.domains[0].domain_name

  # Account settings
  account_enabled = true
}
