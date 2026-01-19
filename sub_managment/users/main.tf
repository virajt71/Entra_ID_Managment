# User Management Module - Reading from CSV
module "user_management" {
  source = "../../modules/management/users-management"

  # CSV file path (relative to this terraform file)
  csv_file_path = "../users.csv"

  # Company configuration (optional - will be auto-detected from tenant if not provided)
  company_name   = "" # Leave empty to use tenant domain
  company_domain = "" # Leave empty to auto-generate from company_name or tenant

}

# Get current subscription info for reference
data "azurerm_client_config" "current" {}
