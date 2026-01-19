# Local processing of CSV data
locals {
  # Determine company domain first
  company_domain = var.company_domain != "" ? var.company_domain : (
    var.company_name != "" ? "${replace(lower(var.company_name), " ", "")}.com" :
    data.azuread_domains.tenant_domains.domains[0].domain_name
  )

  # Read and parse CSV file
  csv_data = var.csv_file_path != "" ? csvdecode(file(var.csv_file_path)) : []

  # Process CSV data and generate user objects
  users_from_csv = [
    for user in local.csv_data : {
      user_key              = lower(replace("${user.given_name}_${user.surname}", " ", "_"))
      user_principal_name   = "${lower(user.given_name)}_${lower(user.surname)}@${local.company_domain}"
      display_name          = "${user.given_name} ${user.surname}"
      given_name            = user.given_name
      surname               = user.surname
      mail_nickname         = lower(replace("${user.given_name}${user.surname}", " ", ""))
      password              = coalesce(user.password, var.default_password)
      force_password_change = tobool(lower(coalesce(user.force_password_change, "true")))
      job_title             = user.job_title
      department            = user.department
    }
  ]
}
