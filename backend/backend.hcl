# Backend Configuration Template
# Use this file with 'terraform init -backend-config=backend/backend.hcl'
# Update the values below to match your Azure Storage Account for Terraform state

resource_group_name  = "tfstate-rg"
storage_account_name = "tfstate<REPLACE_WITH_UNIQUE_SUFFIX>"  # Must be globally unique (alphanumeric, 3-24 chars)
container_name       = "tfstate"

# Individual state keys for each component:
# - backend/terraform.tfstate
# - envs/dev/terraform.tfstate
# - envs/staging/terraform.tfstate
# - envs/prod/terraform.tfstate
# - sub_managment/users/terraform.tfstate
# - sub_managment/groups/terraform.tfstate
# - sub_managment/rbac/terraform.tfstate

# SECURITY NOTE:
# - Enable Azure Storage encryption (automatic for Azure Storage accounts)
# - Use Azure RBAC to restrict access to storage account
# - Enable blob versioning and soft delete for state recovery
# - Consider enabling storage account firewall to restrict network access
